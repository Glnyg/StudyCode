# Service Boundaries And Runtime Topology

## Service Boundaries

| Service | Owns | Does Not Own | Sync Dependencies | Async Dependencies |
| --- | --- | --- | --- | --- |
| `api-gateway` | frontend entry routing, auth forwarding, coarse request policies | business data | downstream service HTTP/gRPC | none |
| `realtime-gateway` | SignalR connections, tenant-aware groups, supervisor fan-out | message truth, routing decisions | `identity-service`, `conversation-service`, `routing-service` | domain events |
| `identity-service` | local accounts, roles, permissions, token issuance | queueing, conversations | PostgreSQL | none |
| `channel-service` | upstream webhook validation, channel normalization, media callback intake | durable conversation state | `conversation-service`, `media-service` | none |
| `conversation-service` | messages, conversation state, audit trail, evaluations | queue strategy, AI policy, search indexes | PostgreSQL, `routing-service` | publishes domain events |
| `routing-service` | queue, assignment, transfer, agent presence, inactivity offline, intervention rules, urgent intervention lifecycle, management alert dispatch | message persistence | PostgreSQL, Redis, `device-service` | publishes routing events |
| `media-service` | object storage writes, media metadata, fixed asset library, media security workflow | AI reasoning, conversation truth | MinIO/S3, PostgreSQL | media processing jobs |
| `search-service` | OpenSearch projection, search APIs, autocomplete, search rebuild | source-of-truth messages | OpenSearch, `conversation-service` | consumes conversation events |
| `knowledge-service` | document import, chunking orchestration, embedding jobs, knowledge releases | chat policy execution | PostgreSQL, object storage | knowledge events |
| `ai-service` | orchestration, policy engine, multimodal decisioning, tools, AI audit | source-of-truth business data | `knowledge-service`, `device-service`, model gateway | AI audit events |
| `device-service` | external device/order API anti-corruption layer and controlled actions | queueing, AI policy | upstream APIs, PostgreSQL cache | device action events |
| `analytics-service` | KPIs, QA read models, aggregate dashboards | transaction truth | PostgreSQL read models | consumes business events |

## Runtime Lanes
- Hot path:
  - `channel-service -> conversation-service -> RabbitMQ -> realtime-gateway`
- Control lane:
  - `routing-service`, `identity-service`
- Intervention lane:
  - `conversation-service -> RabbitMQ -> routing-service -> device-service(optional) -> management notification providers`
- Search lane:
  - `conversation-service -> RabbitMQ -> search-service -> OpenSearch`
- AI lane:
  - `conversation-service -> ai-service -> knowledge-service/device-service/model gateway`
- Media lane:
  - `channel-service -> media-service -> object storage`
- Analytics lane:
  - event consumers and read-model builders only

## Hard Runtime Rules
- No service may bypass another service's owned tables.
- No service may query OpenSearch to reconstruct source-of-truth conversations.
- `search-service` may only consume events or read published projections, never mutate transactional state.
- `ai-service` may never write device facts or conversation truth directly; it issues explicit commands to owned services.
- `realtime-gateway` may never invent or reorder business events; it only pushes already-decided state changes.
- High-risk keyword intervention and management notification must remain asynchronous side-lane work; they may not delay inbound ack or agent push.

## Kubernetes Topology
- Namespace groups:
  - `edge`
  - `core`
  - `ai`
  - `ops`
- Node pools:
  - `gateway`: `api-gateway`, `realtime-gateway`
  - `core`: identity, channel, conversation, routing, search, media, knowledge, device, analytics
  - `ai`: `ai-service`, embedding workers, evaluation workers
  - `stateful`: OpenSearch, PostgreSQL, RabbitMQ, Redis if self-hosted in-cluster

## Stateful Placement Rules
- Preferred production pattern:
  - OpenSearch, PostgreSQL, RabbitMQ, Redis run on isolated stateful nodes or equivalent managed/independent infrastructure.
- Forbidden pattern:
  - co-scheduling stateful clusters with noisy AI inference or stateless gateway workloads on the same worker pool.

## Scale Units
- `realtime-gateway`: scale by concurrent connections and outbound push latency.
- `conversation-service`: scale by message ingest rate.
- `search-service`: scale separately for indexing and query workloads.
- `ai-service`: scale by model latency and tool-call throughput.
- `routing-service`: scale by queue mutation rate and agent state churn.
- `routing-service` intervention workers: scale by matched-message throughput, enrichment latency, and notification retry volume.

# Implementation Readiness And Design Freeze

## Goal
Define what is already frozen at the architecture level, what is still missing before implementation, and the required order for turning the blueprint into executable project work.

## Current Status
The system is already complete at the blueprint level.

The following decisions are considered frozen unless changed by ADR:
- runtime baseline: `.NET 10 LTS`
- deployment baseline: `RKE2 Kubernetes`, single production cluster, multi-node HA
- service topology: `2` edge services + `10` business services
- truth vs read-side split:
  - `PostgreSQL + pgvector` as source of truth
  - `OpenSearch` as chat-history search read-side only
  - `Redis` as ephemeral state only
  - `RabbitMQ` as async delivery only
  - `MinIO/S3` as object storage only
- realtime hot path rules and side-lane rules
- AI service boundaries, policy model, multimodal V1 scope, and tool-execution constraints
- failure recovery semantics for single service and single worker-node loss
- official implementation style:
  - `Pragmatic DDD` in core transactional domains
  - `Workflow-first` in orchestration, adapter, and projection-heavy services
  - `Selective CQRS`
  - `Layered TDD`

## What Is Not Missing Anymore
The project does not need more first-order architecture debate on these topics before coding:
- `.NET 10` vs `.NET 8`
- whether PostgreSQL can remain the AI truth store
- whether chat search needs `OpenSearch`
- whether every service must use full DDD/CQRS
- whether V1 should support video understanding in the AI hot path

Those choices are already good enough for implementation planning.

## What Is Still Missing Before Real Coding
The remaining gaps are implementation-freeze items, not architecture-direction items.

### P0: Contract Package V1
Must be frozen before shared service scaffolding.

Required artifacts:
- OpenAPI specs for public HTTP APIs
- `proto` files for gRPC contracts
- event schema files and compatibility rules
- standard error catalog and error-code format
- paging, idempotency, concurrency, and trace-header conventions
- request/response examples for operator console and internal service calls

Must cover at least:
- `conversation-service`
- `routing-service`
- `search-service`
- `media-service`
- `ai-service`
- shared event envelope

Done means:
- contracts are specific enough to generate server/client stubs or DTOs
- breaking changes can be detected in review
- event and API examples are no longer only illustrative prose

### P0: PostgreSQL Detailed Schema V1
Must be frozen before domain implementation and migrations.

Required artifacts:
- table-by-table logical schema for each source-of-truth service
- primary keys, unique keys, foreign-key strategy where applicable
- time partition rules
- indexes for hot queries
- idempotency keys
- sequence rules for conversation replay
- audit columns
- outbox and inbox schema details
- retention and archive hooks

Done means:
- migrations can be written without inventing core business columns on the fly
- replay, dedupe, and audit behavior are encoded in schema rules instead of chat memory

### P0: Tenant Resolution And Authorization V1
Must be frozen before identity and gateway work.

Required artifacts:
- trusted tenant-resolution rules by entry type:
  - operator console
  - Enterprise WeChat webhook
  - internal event
- token claims shape
- tenant-scoped RBAC permission matrix
- platform-admin boundary rules
- audit requirements for privileged operations
- forbidden implicit-tenant patterns

Done means:
- every request path has a single trusted tenant-resolution rule
- no service needs to guess tenant from optional client input
- authorization work can start without redefining roles per module

### P0: Upstream Integration Specs V1
Must be frozen before `channel-service` and `device-service`.

Required artifacts:
- Enterprise WeChat customer-service webhook contract
- official-account callback contract
- upstream retry and dedupe behavior
- media callback and media-fetch flow
- outbound send contract and provider idempotency strategy
- device/order/after-sales upstream API mapping
- reconciliation and compensation rules after partial failure

Done means:
- adapter code can be implemented against explicit upstream semantics
- retry and duplicate-delivery behavior is designed, not improvised

### P0: Engineering Baseline V1
Must be frozen before broad scaffolding across services.

Required artifacts:
- repository layout and solution structure
- shared-building-block boundaries
- package/version management strategy
- local development topology
- configuration layering by environment
- CI pipeline stages
- Helm chart and values conventions
- environment matrix:
  - local
  - dev
  - staging
  - production

Done means:
- new services follow one repository shape
- local bring-up and CI checks are reproducible
- deployment manifests do not diverge service by service without rules

## P1 Items That May Follow Initial Scaffolding
These do not block the first shared skeleton, but they must be frozen before the related milestone starts.

### Search Freeze Package
- final OpenSearch mappings
- index template and lifecycle policy
- projection replay contract
- rebuild job API and operational runbook

### AI Freeze Package
- policy/config schema fields
- publish/rollback workflow
- prompt assembly rules
- tool manifest format
- audit payload schema
- evaluation metric definitions

### Media And Asset Freeze Package
- media-processing job contract
- virus scan and moderation states
- asset review workflow
- URL signing and preview rules

### Observability And SRE Freeze Package
- service SLOs
- latency/error/saturation alerts
- dashboards and trace requirements
- failure-drill scripts and ownership

### Intervention And Notification Freeze Package
- intervention rule schema and severity model
- cooldown and dedupe rules
- management notification endpoint model and secret-reference rules
- payload templates and redaction rules
- acknowledgement and resolution workflow
- device-enrichment timeout and fallback rules
- provider retry and dead-letter runbook

## Recommended Delivery Order
1. Freeze shared contracts and repository baseline.
2. Freeze tenant resolution and authorization model.
3. Implement `conversation-service` source-of-truth core plus outbox.
4. Implement `routing-service` and `realtime-gateway`.
5. Implement `channel-service` inbound and outbound adapters.
6. Implement `search-service` projection and query path.
7. Implement `media-service` and asset governance.
8. Implement `knowledge-service` and `ai-service`.
9. Implement `analytics-service`.
10. Harden platform delivery, drills, and production operations.

## Definition Of Ready For Coding
Coding may start when all of the following are true:
- blueprint docs and ADR baseline are approved
- contract package V1 is frozen for the slice being built
- data model V1 is frozen for the slice being built
- tenant/auth rules are frozen for the slice being built
- tests required for that slice are known up front
- implementation order does not depend on unresolved architecture arguments

## Definition Of Ready For The First Milestone
The first milestone is the realtime conversation loop.

Do not start it until these are frozen:
- inbound message contract
- agent send contract
- message, conversation, outbox, and replay schema
- tenant resolution rules for console and channel webhook
- queue assignment interaction between `conversation-service` and `routing-service`
- websocket replay contract with `message_id` and `sequence`
- duplicate-delivery and retry semantics

## Governance Rule
If a future discussion reopens a topic already frozen in this document, the default answer is:
- do not redesign the architecture
- add a precise gap to the corresponding freeze package
- only create a new ADR if runtime, data ownership, or safety boundaries truly change

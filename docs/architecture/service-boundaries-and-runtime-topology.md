# Service Boundaries And Runtime Topology（服务边界与运行时拓扑）

## Service Boundaries（服务边界）

| Service | Owns（拥有） | Does Not Own（不拥有） | Sync Dependencies（同步依赖） | Async Dependencies（异步依赖） |
| --- | --- | --- | --- | --- |
| `api-gateway` | frontend entry routing（前端入口路由）、auth forwarding（鉴权转发）、coarse request policies（粗粒度请求策略） | business data（业务数据） | downstream service HTTP/gRPC | none |
| `realtime-gateway` | SignalR connections、tenant-aware groups（租户分组）、supervisor fan-out（主管分发） | message truth、routing decisions | `identity-service`、`conversation-service`、`routing-service` | domain events |
| `identity-service` | local accounts、roles、permissions、token issuance | queueing、conversations | PostgreSQL | none |
| `channel-service` | upstream webhook validation、channel normalization、media callback intake | durable conversation state | `conversation-service`、`media-service` | none |
| `conversation-service` | messages、conversation state、audit trail、evaluations | queue strategy、AI policy、search indexes | PostgreSQL、`routing-service` | publishes domain events |
| `routing-service` | queue、assignment、transfer、agent presence、inactivity offline、intervention rules、urgent intervention lifecycle、response-timeout policies、response-timeout alert lifecycle、management alert dispatch | message persistence | PostgreSQL、Redis、`device-service` | publishes routing events |
| `media-service` | object storage writes、media metadata、fixed asset library、media security workflow | AI reasoning、conversation truth | MinIO/S3、PostgreSQL | media processing jobs |
| `search-service` | OpenSearch projection、search APIs、autocomplete、search rebuild | source-of-truth messages | OpenSearch、`conversation-service` | consumes conversation events |
| `knowledge-service` | document import、chunking orchestration、embedding jobs、knowledge releases | chat policy execution | PostgreSQL、object storage | knowledge events |
| `ai-service` | orchestration、policy engine、multimodal decisioning、tools、AI audit | source-of-truth business data | `knowledge-service`、`device-service`、model gateway | AI audit events |
| `device-service` | external device/order API anti-corruption layer（防腐层）与 controlled actions | queueing、AI policy | upstream APIs、PostgreSQL cache | device action events |
| `analytics-service` | KPIs、QA read models、aggregate dashboards | transaction truth | PostgreSQL read models | consumes business events |

## Runtime Lanes（运行时通道）
- Hot path（热路径）：
  - `channel-service -> conversation-service -> RabbitMQ -> realtime-gateway`
- Control lane（控制通道）：
  - `routing-service`、`identity-service`
- Management alert lane（管理告警通道）：
  - `conversation-service -> RabbitMQ -> routing-service -> device-service(optional) -> management notification providers`
- Search lane（搜索通道）：
  - `conversation-service -> RabbitMQ -> search-service -> OpenSearch`
- AI lane（AI 通道）：
  - `conversation-service -> ai-service -> knowledge-service/device-service/model gateway`
- Media lane（媒体通道）：
  - `channel-service -> media-service -> object storage`
- Analytics lane（分析通道）：
  - 仅事件 consumers 和 read-model builders

## Hard Runtime Rules（硬性运行时规则）
- 任何 service 都不能绕过别人的 owned tables（归属表）直接写数据。
- 任何 service 都不能通过 OpenSearch 重建 source-of-truth conversations。
- `search-service` 只能消费 events 或读取已发布 projections，不能改写 transactional state。
- `ai-service` 不能直接写 device facts 或 conversation truth；它只能向拥有这些真相的服务发显式 commands。
- `realtime-gateway` 不能发明、重排或推测 business events；它只能推送已经决定好的状态变更。
- 高风险关键词介入、assigned-agent response-timeout alerting、management notification 都必须保持 asynchronous side-lane（异步旁路）属性，不能拖慢 inbound ack 或 agent push。

## Kubernetes Topology（Kubernetes 拓扑）
- Namespace groups（命名空间分组）：
  - `edge`
  - `core`
  - `ai`
  - `ops`
- Node pools（节点池）：
  - `gateway`：`api-gateway`、`realtime-gateway`
  - `core`：identity、channel、conversation、routing、search、media、knowledge、device、analytics
  - `ai`：`ai-service`、embedding workers、evaluation workers
  - `stateful`：OpenSearch、PostgreSQL、RabbitMQ、Redis（如自托管）

## Stateful Placement Rules（有状态组件放置规则）
- Preferred production pattern（推荐生产模式）：
  - OpenSearch、PostgreSQL、RabbitMQ、Redis 运行在隔离的 stateful nodes（有状态节点）或等价的独立/托管基础设施上。
- Forbidden pattern（禁止模式）：
  - 不允许把 stateful clusters（有状态集群）和 noisy AI inference（高噪声 AI 推理）或 stateless gateway workloads 混布在同一 worker pool。

## Scale Units（扩缩容单位）
- `realtime-gateway`：按 concurrent connections（并发连接数）和 outbound push latency（出站推送延迟）扩缩。
- `conversation-service`：按 message ingest rate（消息写入速率）扩缩。
- `search-service`：indexing workloads（索引工作负载）与 query workloads（查询工作负载）分开扩缩。
- `ai-service`：按 model latency 和 tool-call throughput 扩缩。
- `routing-service`：按 queue mutation rate 和 agent state churn 扩缩。
- `routing-service` 的 management-alert workers：按 matched-message throughput、waiting-window volume、enrichment latency、notification retry volume 扩缩。

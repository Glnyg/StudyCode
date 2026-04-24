# Power Loss And Recovery（掉电与恢复）

## Goal（目标）
保证单个 stateless service instance（无状态服务实例）故障，或单个 Kubernetes worker node（工作节点）掉电时，不会丢失已经 acknowledged（已确认）的聊天消息，并且主聊天流程能在重启或重新调度后自动恢复。

## In Scope（范围内）
- 单个 application Pod crash（应用 Pod 崩溃）
- 单个 Kubernetes worker node 掉电
- 单个 realtime gateway instance 丢失
- 在 quorum queues（仲裁队列）健康的前提下，单个 RabbitMQ 节点丢失
- 在 HA failover（高可用切换）正常的前提下，PostgreSQL primary instance 丢失

## Out Of Scope（范围外）
- 整个 cluster 掉电
- region 或 data-center outage（机房级故障）
- 跨副本的永久多盘损坏
- 上游 provider（供应商）既不支持 idempotency（幂等）也不给 dedupe key（去重键）的行为

## Recovery Semantics（恢复语义）
- 如果系统已经确认了 inbound message（入站消息），那条消息必须已经 durable（持久）地写入 PostgreSQL source-of-truth storage。
- realtime push（实时推送）在故障期间可以中断，但客户端必须通过 reconnect + replay（重连 + 重放）从 source truth 恢复缺失消息。
- Search、analytics 和 AI side lanes（旁路）在恢复后可以 lag 或 replay，但不能阻塞 chat truth。
- 任何 retry path（重试路径）都不能在重启后制造重复的 business side effects（业务副作用）。

## Component Requirements（组件要求）

### Stateless Services（无状态服务）
- 所有 hot-path stateless services 在生产环境至少运行 `2` 个副本。
- 副本必须通过 anti-affinity（反亲和）或 topology spread constraints（拓扑分散约束）分布在不同节点。
- readiness 和 liveness probes（探针）是强制项。
- Pod 重启后恢复正常流量不允许依赖人工干预。

### PostgreSQL
- PostgreSQL 是已确认消息和 conversation state（会话状态）的唯一 source of truth。
- 生产环境必须具备 HA failover、durable storage（持久存储）、WAL persistence（预写日志持久化）和自动主库提升。
- inbound message success（入站消息成功）只能在以下本地事务成功提交之后才允许确认：
  - `message_log`
  - `conversation_event`（如果适用）
  - `outbox_message`
- recovery 过程中允许 replay outbox delivery（重放发件箱投递），但不能复制 source-of-truth messages。

### RabbitMQ
- 关键领域事件必须使用 durable queues 和 `quorum queues`。
- producers（生产者）必须启用 publisher confirms（发布确认）。
- consumers（消费者）只能在本地 idempotent transaction（幂等事务）提交成功之后确认消费。
- 重启后的 replay delivery（重放投递）是预期行为，并且必须安全。

### Redis
- Redis 可以丢失 transient state（临时状态），但这不能破坏消息持久化保证。
- presence、websocket grouping hints（分组提示）和短期 idempotency windows 可以在重启后重建。
- Redis 绝不能成为 message、routing 或 audit truth 的唯一持有者。

### Object Storage（对象存储）
- media files（媒体文件）和 fixed assets（固定素材）必须先写入 durable object storage，后续流程才能依赖它们。
- metadata 和 object keys 的 source-of-truth 仍在各自拥有的数据库里；如果文件已经存在，media processing（媒体处理）可以安全 replay。

## Main Flow Rules（主流程规则）

### Inbound Customer Message（客户入站消息）
1. `channel-service` 校验并归一化入站请求。
2. `conversation-service` 以事务方式把消息写入 PostgreSQL，并在同一事务里写入 outbox record。
3. 只有 commit 成功之后，系统才能向上游渠道返回 success。
4. outbox relayer（发件箱中继）通过 publisher confirm 把 domain event 发布到 RabbitMQ。
5. `realtime-gateway`、`search-service`、`ai-service` 和 `analytics-service` 异步消费这些事件。

### Agent Outbound Message（客服外发消息）
1. agent send request（客服发送请求）必须先在 PostgreSQL 中创建 durable outbound intent record（持久外发意图记录），再调用上游。
2. `channel-service` 调用上游时必须使用 idempotency key 或 provider 支持的 dedupe field（去重字段）。
3. 如果在 durable intent 写入后、上游确认前发生崩溃，recovery 必须重试同一个 intent。
4. 如果上游已经确认，但本地状态更新失败，reconciliation（对账修复）必须补齐最终状态，并在 provider 支持幂等时避免重复发送用户可见消息。

## Reconnect And Replay（重连与重放）
- 每条 conversation message 都必须携带 monotonic `sequence`（单调递增序号）。
- client 按 conversation 跟踪 `last_seen_sequence`。
- websocket 重连后，client 必须从最后确认的 `sequence` 开始请求 replay。
- 因此 realtime delivery 允许 at-least-once（至少一次）；UI 必须按 `message_id` + `sequence` 做幂等应用。

## Recovery By Failure Type（按故障类型的恢复）

### Single Application Pod Crash（单个应用 Pod 崩溃）
- Kubernetes 会重启或重新调度该 Pod。
- 任何未确认请求（unacked request）由调用方或上游 webhook 重试。
- 任何已确认消息都保留在 PostgreSQL 中，并且可以 replay。

### Single Worker Node Power Loss（单个工作节点掉电）
- 失败节点上的 Pods 会在其他节点重建。
- 只要每个关键无状态服务至少还有一个健康副本，hot path 就必须继续。
- 客户端应重连到健康的 realtime gateways，并重放缺失消息。

### Realtime Gateway Loss（实时网关丢失）
- 连接会短暂中断。
- 不会丢失业务真相（business truth）。
- reconnect + replay 会恢复可见会话状态。

### Search Or AI Worker Loss（搜索或 AI worker 丢失）
- chat truth 和 routing 继续运行。
- search indexing 和 AI side effects 在 worker 恢复后，从 RabbitMQ 或 source truth 重放。

## Forbidden Patterns（禁止模式）
- 在 PostgreSQL commit 之前确认 inbound success
- 依赖 Redis 保存唯一的 business state 副本
- 在重启后把 OpenSearch 当成 replay truth
- 在没有 idempotent handling（幂等处理）的情况下消费 RabbitMQ 消息
- 使用会重复用户可见副作用的 silent “best effort” outbound retries（静默尽力重试）

## Verification Requirements（验证要求）
- 在 live chat traffic（在线聊天流量）运行时，对无状态服务节点做 power-off drill（断电演练）
- 在 active sessions（活跃会话）期间，对 realtime gateway 节点做 power-off drill
- 对 RabbitMQ consumer 做 restart drill（重启演练），验证 duplicate delivery replay
- 对 websocket clients 做 replay drill，验证它们能按 `sequence` 恢复缺失消息
- 对 PostgreSQL primary 做 failover drill（主库切换演练），验证已确认入站消息不丢失

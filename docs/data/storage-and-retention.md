# Storage And Retention（存储与保留策略）

## Storage Responsibilities（存储职责）

| 存储 | 角色 | 是否持有事实真相 | 说明 |
| --- | --- | --- | --- |
| PostgreSQL | transactions（事务）、audit（审计）、AI config、knowledge metadata、embeddings | Yes | 按服务拥有 schema 或 database；已确认的入站聊天真相必须先提交到这里 |
| OpenSearch | chat search read-side（聊天搜索读侧） | No | 必须能从 source truth（事实源）和 events 重建 |
| Redis | presence（在线状态）、short-lived cache（短期缓存）、backplane、idempotency windows（幂等窗口） | No | key 必须带 tenant 前缀 |
| RabbitMQ | async workflow（异步工作流）和 event delivery（事件投递） | No | 关键领域事件必须配 outbox / inbox 和 durable quorum queues |
| MinIO/S3 | attachments（附件）、raw documents（原始文档）、fixed assets（固定素材） | No | object metadata（对象元数据）仍归各服务拥有 |

## PostgreSQL Core Models（PostgreSQL 核心模型）
- `conversation-service`
  - `message_log`
  - `conversation_event`
  - `conversation_projection`
  - `evaluation`
  - `outbox_message`
- `routing-service`
  - `queue`
  - `queue_ticket`
  - `assignment`
  - `transfer`
  - `agent_presence`
- `media-service`
  - `media_object`
  - `media_review`
  - `asset_item`
  - `link_card_template`
- `ai-service`
  - `prompt_profile`
  - `reply_policy`
  - `tool_policy`
  - `asset_selection_policy`
  - `tenant_ai_settings`
  - `ai_audit`
- `knowledge-service`
  - `knowledge_document`
  - `knowledge_document_version`
  - `knowledge_chunk`
  - `knowledge_chunk_embedding`
  - `knowledge_release`
  - `knowledge_feedback`

## Partitioning Rules（分区规则）
- `message_log` 按 `occurred_at` 做 monthly partitioning（按月分区）。
- 大型 audit / event 表应复用同样的 time-based partitioning pattern（按时间分区模式）。
- chat replay（聊天重放）和 retention jobs（保留策略作业）的查询，只要可能都必须带时间范围。

## Retention Rules（保留规则）
- OpenSearch 中的 chat search projection（聊天搜索投影）：
  - 在线保留 365 天
- PostgreSQL 中的 chat transactional truth（聊天事务真相）：
  - 按业务/法律策略保留，不会随着 search projection 删除而自动删除
- Redis：
  - 只存 ephemeral data（临时数据）
- RabbitMQ：
  - 在 consumer 成功消费或 dead-letter policy（死信策略）处理 poison messages（毒消息）之前保持 durable
- object storage：
  - 原始素材遵循各服务级 retention 和 legal hold policies（法律保留策略）

## Multi-Tenant Data Rules（多租户数据规则）
- 每一行持久化业务数据都必须包含 `tenant_id`，除非它是真正 global（全局）且有显式保护的记录。
- cache keys（缓存键）必须以 `tenant_id` 开头。
- search documents（搜索文档）必须包含 `tenant_id`。
- object keys（对象键）必须按租户分域，例如：
  - `tenant-a/channel/2026/04/24/msg-001/image-original.jpg`

## OpenSearch Is Derived Data（OpenSearch 是派生数据）
- 绝不能只在 OpenSearch 里修补 business truth（业务真相）。
- 绝不能把 OpenSearch 当成 replay、audit、billing 或 device operations 的 authoritative source（权威来源）。
- rebuildability（可重建性）是硬要求：一旦 search index 丢失，必须能从 PostgreSQL + events 重新构建。

## Recovery Rules（恢复规则）
- inbound message success（入站消息成功）只能在 PostgreSQL source-of-truth commit 成功之后才能确认。
- outbox relay（发件箱中继）在重启后必须可以安全重试。
- consumer projections（消费者投影）必须 replay-safe 且 idempotent。

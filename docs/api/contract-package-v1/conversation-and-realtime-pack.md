# Conversation And Realtime Pack（会话与实时合同包）

## Scope（范围）
- 冻结 operator console 直接依赖的 conversation HTTP 合同。
- 冻结 `realtime-gateway` 的最小 connect / subscribe / ack / replay 语义。
- 冻结 `conversation-service` 发布给 `routing-service`、`search-service`、`ai-service`、`realtime-gateway` 的核心事件字段。

## APIs（接口）
- `OpenAPI`: [openapi/conversation-service.openapi.yaml](./openapi/conversation-service.openapi.yaml)
- `OpenAPI`: [openapi/edge-boundaries.openapi.yaml](./openapi/edge-boundaries.openapi.yaml)

### HTTP Surface（HTTP 接口面）
- `GET /v1/conversations`
- `GET /v1/conversations/{conversation_id}/messages`
- `POST /v1/conversations/{conversation_id}/messages`
- `POST /v1/conversations/{conversation_id}:evaluate`

### Realtime Boundary（实时边界）
- connect（连接）：
  - 必须携带 bearer token
  - server 负责解析 trusted `TenantContext`
- client -> server：
  - `SubscribeConversation`
  - `AckConversationPosition`
  - `ReplayConversationFromSequence`
- server -> client：
  - `ConversationMessageCommitted`
  - `ConversationStateChanged`
  - `ConversationAssignmentChanged`

## Event Schemas（事件 Schema）
- `JSON Schema`: [schemas/conversation-events.schema.json](./schemas/conversation-events.schema.json)
- 当前覆盖的 event types（事件类型）：
  - `MessageAppended`
  - `MessageRedacted`
  - `ConversationClosed`
  - `ConversationTagged`

## Contract Rules（合同规则）
- `POST /v1/conversations/{conversation_id}/messages` 必须带 `Idempotency-Key`。
- message replay（消息重放）必须使用 `message_id + sequence`。
- `sequence` 是 per-conversation（按会话）的单调递增 committed sequence。
- API 可以按时间倒序返回；realtime replay 必须按 `sequence asc` 返回。
- 如果 `conversation_id` 存在但不属于当前 tenant，返回 `404 conversation.not_found`，不泄露 cross-tenant existence（跨租户存在性）。

## Negative Cases（负例）
- missing tenant context（缺少租户上下文）：
  - `401 tenant.context_missing` 或 `403 tenant.forbidden_cross_tenant`
- duplicate outbound send with same key and same payload（相同 key + 相同载荷重复发送）：
  - 返回同一个 intent 结果
- duplicate outbound send with same key but different payload（相同 key + 不同载荷重复发送）：
  - `409 conflict.idempotency_payload_mismatch`
- replay from a future `last_seen_sequence`（从未来序号重放）：
  - `409 conversation.invalid_replay_position`

## Compatibility Notes（兼容性说明）
- `MessageAppended` 可以新增 optional structured business facts（可选结构化业务事实），但不能改变 `message_id`、`sequence`、`occurred_at` 的语义。
- `ConversationStateChanged` 这一轮只冻结最小 server event 名称和 payload 形状，不冻结前端展示字段。

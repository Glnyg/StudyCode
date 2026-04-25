# Routing And Alerting Pack（路由与告警合同包）

## Scope（范围）
- 冻结 queue、assignment、transfer、agent presence 的 control-plane API（控制面接口）。
- 冻结 urgent intervention 与 response-timeout 的配置、列表、ack / resolve 行为。
- 冻结 `routing-service` 对外发布的路由与告警事件。

## APIs（接口）
- `OpenAPI`: [openapi/routing-service.openapi.yaml](./openapi/routing-service.openapi.yaml)

### HTTP Surface（HTTP 接口面）
- `GET /v1/queues`
- `POST /v1/conversations/{conversation_id}:assign`
- `POST /v1/conversations/{conversation_id}:transfer`
- `PUT /v1/agents/{agent_id}/presence`
- `GET /v1/intervention-rules`
- `PUT /v1/intervention-rules/{rule_id}`
- `GET /v1/response-timeout-policies`
- `PUT /v1/response-timeout-policies/{policy_id}`
- `GET /v1/urgent-interventions`
- `POST /v1/urgent-interventions/{intervention_id}:acknowledge`
- `POST /v1/urgent-interventions/{intervention_id}:resolve`
- `GET /v1/response-timeout-alerts`

## Event Schemas（事件 Schema）
- `JSON Schema`: [schemas/routing-alerting-events.schema.json](./schemas/routing-alerting-events.schema.json)
- 当前覆盖的 event types 包括：
  - `ConversationAssigned`
  - `TransferCompleted`
  - `AgentPresenceChanged`
  - `AiHandoffChanged`
  - `UrgentInterventionTriggered`
  - `UrgentInterventionAcknowledged`
  - `ResponseTimeoutAlertTriggered`
  - `ResponseTimeoutAlertCleared`
  - `ManagementNotificationDispatched`

## Contract Rules（合同规则）
- assignment / transfer API 必须带 `Idempotency-Key`。
- versioned config writes（带版本配置写入）必须带 `If-Match`。
- 所有 routing operator surface 都必须显式声明所需 `x-required-permissions`。
- routing operator error（路由操作员错误）必须直接返回真实 HTTP status，不允许 outer `200 + inner error`。
- 所有 `GET` routing surface 都不接受 request body。
- response-timeout 和 urgent intervention 的 notification delivery 都必须按 `source_type + source_id + endpoint_id + template_version` 去重。
- `routing-service` 可以消费 `MessageAppended`、`ConversationClosed`，但不能改写 `conversation-service` 拥有的消息真相。

## Negative Cases（负例）
- valid token but missing `conversation.assign` / `conversation.transfer` / `routing.rule.write` / `routing.alert.manage`（权限不足）：
  - `403 routing.permission_denied`
- `GET /v1/queues`、`GET /v1/urgent-interventions` 等带 request body：
  - `400 gateway.request_invalid`
- assigning a conversation already assigned to another agent without transfer（未转接直接抢占已分配会话）：
  - `409 routing.assignment_conflict`
- updating a rule with stale `If-Match`（用过期版本更新规则）：
  - `409 conflict.version_mismatch`
- acknowledging an intervention from another tenant（确认其他租户的 intervention）：
  - `404 routing.intervention_not_found`
- `platform_admin` 直接走 tenant-scoped routing API：
  - `403 gateway.admin_surface_required`
- no active human assignment for response-timeout lookup（查询时没有活跃人工分配）：
  - 返回空列表或 no-op，不生成 alert

## Compatibility Notes（兼容性说明）
- `ResponseTimeoutAlertTriggered` 的 `dedupe_key` 语义固定为 `tenant_id + waiting_message_id + assignment_id`，没有 ADR 不得修改。
- `ManagementNotificationDispatched` 继续兼容 legacy records（历史记录）缺少 `source_type` / `source_id` 的场景，但新 producer 必须始终写入。

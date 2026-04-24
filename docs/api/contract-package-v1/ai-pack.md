# AI Pack（AI 合同包）

## Scope（范围）
- 冻结 AI reply suggestion、decision execute、policy snapshot、audit list 的 HTTP 合同。
- 冻结 `AiDecisionContext`、tool execution request / result、asset selection、fallback reason 的可见结构。
- 冻结 AI 输出与审计必须满足的最小字段。

## APIs（接口）
- `OpenAPI`: [openapi/ai-service.openapi.yaml](./openapi/ai-service.openapi.yaml)

### HTTP Surface（HTTP 接口面）
- `POST /v1/ai/reply-suggestions`
- `POST /v1/ai/decisions:execute`
- `GET /v1/ai/policies/current`
- `GET /v1/ai/audit-records`

## Event Schemas（事件 Schema）
- `JSON Schema`: [schemas/asset-ai-events.schema.json](./schemas/asset-ai-events.schema.json)
- 当前覆盖的 event types：
  - `VideoEscalatedToHuman`
  - `KnowledgeReleasePublished`
  - `LowRiskToolExecuted`

## Contract Rules（合同规则）
- `POST /v1/ai/decisions:execute` 必须带 `Idempotency-Key`。
- tool execution result（工具执行结果）必须显式返回：
  - `execution_mode`
  - `idempotency_key`
  - `precondition_status`
  - `fallback_reason`
- AI video 输入一律不进入理解路径，直接返回 human handoff / escalation contract（转人工 / 升级合同）。
- audit record（审计记录）最少必须包括：
  - `tenant_id`
  - `conversation_id`
  - `mode`
  - `policy_version`
  - `prompt_version`
  - `model_name`
  - `confidence`
  - `tool_calls`
  - `asset_choice`
  - `fallback_reason`

## Negative Cases（负例）
- policy load failure（策略加载失败）：
  - `503 ai.policy_load_failed`
- tool blocked by policy（工具被策略阻止）：
  - `403 ai.tool_execution_forbidden`
- video input in assist path（辅助路径收到视频输入）：
  - `409 ai.video_requires_human_handoff`
- asset selected but not reviewed / effective（选中的素材未审核或未生效）：
  - `409 ai.asset_selection_invalid`

## Compatibility Notes（兼容性说明）
- `fallback_reason` 可以新增 enum value（枚举值），但旧 consumer 必须按“unknown fallback（未知回退）”处理，不能把未知值默认为 success。
- `tool_calls` 可以新增审计字段，但不能移除 `tool_name`、`execution_mode`、`result_status`。

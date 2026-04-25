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
- 当前 tenant-scoped AI operator surface 只覆盖 suggestion、execute、policy snapshot read、audit read；publish / rollback 写接口不在这一轮 surface 内。
- 需要结构化输入的 suggestion surface 固定使用 `POST /v1/ai/reply-suggestions`；当前包不定义 `GET + request body` 的 AI read surface。
- AI operator error（AI 操作员错误）必须直接返回真实 HTTP status，不允许 outer `200 + inner error`。
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
- 未来任何 AI policy publish / rollback 写接口，都必须显式声明 `ai.policy.publish` 或 `tenant.config.write`，并遵守 `If-Match`、trusted `TenantContext` 和 audit metadata 规则。

## Negative Cases（负例）
- policy load failure（策略加载失败）：
  - `503 ai.policy_load_failed`
- valid token but missing `ai.decision.execute` / `ai.audit.read` / `ai.policy.read`（权限不足）：
  - `403 ai.permission_denied`
- `GET /v1/ai/policies/current` 或 `GET /v1/ai/audit-records` 携带 request body：
  - `400 gateway.request_invalid`
- tool blocked by policy（工具被策略阻止）：
  - `403 ai.tool_execution_forbidden`
- video input in assist path（辅助路径收到视频输入）：
  - `409 ai.video_requires_human_handoff`
- asset selected but not reviewed / effective（选中的素材未审核或未生效）：
  - `409 ai.asset_selection_invalid`
- `platform_admin` 直接走 tenant-scoped AI operator surface：
  - `403 gateway.admin_surface_required`

## Compatibility Notes（兼容性说明）
- `fallback_reason` 可以新增 enum value（枚举值），但旧 consumer 必须按“unknown fallback（未知回退）”处理，不能把未知值默认为 success。
- `tool_calls` 可以新增审计字段，但不能移除 `tool_name`、`execution_mode`、`result_status`。

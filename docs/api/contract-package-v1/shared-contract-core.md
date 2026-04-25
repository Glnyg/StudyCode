# Shared Contract Core（共享合同核心）

## Trusted Request Context（可信请求上下文）
- 客户端可以直接提供的字段只包括：
  - `Authorization`
  - `X-Correlation-Id`
  - `traceparent`
  - `tracestate`
  - `Idempotency-Key`
  - `If-Match`
- `tenant_id` 不能作为可直接信任的客户端 header、query parameter 或 request body field 出现。
- 服务在进入业务处理前，必须构造 trusted `TenantContext`（可信租户上下文）：
  - operator console 请求：来自 token claims + tenant-scoped RBAC
  - channel webhook：来自 verified channel binding
  - internal event：来自 trusted event envelope
- operator console 使用 single-tenant session token（单租户会话令牌）；当前 tenant-scoped operator surfaces 不接受 `platform_admin` 直接复用。
- `TenantContext`、`UserContext`、`OperatorTokenClaims`、`ConversationContext`、`AttachmentRef`、`AssetItem`、`AiDecisionContext`、`AuditEnvelope` 的冻结形状见 `schemas/shared-types.schema.json`。

## Header And Context Rules（Header 与上下文规则）

| Header | 是否必需 | 含义 | 合同规则 |
| --- | --- | --- | --- |
| `Authorization` | operator APIs 必需 | bearer token | claims 必须包含 `sub`, `tenant_id`, `actor_type`, `role`, `permissions`, `session_id`；缺失或 tenant 不匹配时必须 fail closed |
| `X-Correlation-Id` | 入站推荐、响应中必须回显 | request correlation（请求关联） | 如果缺失由服务生成，并写入 response / event envelope |
| `traceparent` | 推荐 | distributed tracing（分布式追踪） | 透传到下游与异步 event |
| `tracestate` | 可选 | vendor trace state（供应商追踪状态） | 原样透传 |
| `Idempotency-Key` | 下列 side-effecting `POST` 必需 | dedupe for retried intent（重试意图去重） | 相同 key + same tenant + same route 必须返回相同语义结果 |
| `If-Match` | versioned config writes 必需 | optimistic concurrency（乐观并发） | mismatch 返回 `409` |

## Authorization Model（授权模型）
- tenant-scoped operator OpenAPI operations（操作员接口）必须显式标注 `x-required-permissions`。
- 授权判断顺序固定为：
  1. 认证是否有效
  2. trusted `TenantContext` 是否已建立
  3. actor 是否拥有所需 `permissions`
  4. resource owner tenant（资源所属租户）是否与 resolved tenant 一致
- `platform_admin` 不复用当前 tenant-scoped operator surfaces；需要单独 admin surface 时，必须显式指定 target tenant 并写入 audit reason（审计原因）。

## HTTP Response Strategy（HTTP 响应策略）
- operator/public HTTP surfaces（操作员 / 公共 HTTP 接口面）出错时，默认返回真实 HTTP status + 统一 error envelope。
- 以下失败禁止用外层 `200` 包装真实失败：
  - authentication / tenant resolution（认证 / 租户解析）
  - permission / admin boundary（权限 / 管理员边界）
  - request-shape / validation（请求形状 / 校验）
  - conflict / not-found（冲突 / 不存在）
  - dependency / internal failure（依赖 / 内部失败）
- 外层 `200` 只保留给“HTTP 成功返回业务状态报告对象”的场景；当前 `Contract Package V1` 不定义任何 operator/public `200 + inner error` surface。
- `GET` operations（操作）不接受 request body，也不定义 body 语义；客户端发送 body 时必须返回真实 `400`。
- 推荐的诊断顺序固定为 `HTTP status -> error_source -> code`。

## Status Code Semantics（状态码语义）
- `400`：
  - `gateway.request_invalid`
  - `<service>.invalid_request`
  - 用于 `GET` request body、malformed query / payload、缺少必需 audit metadata 等 request-shape failure（请求形状失败）
- `401`：
  - `gateway.identity_invalid`
  - `gateway.tenant_context_missing`
  - 用于 trusted tenant context 建立之前的失败
- `403`：
  - `gateway.admin_surface_required`
  - `<service>.permission_denied`
  - `tenant.channel_binding_mismatch`
  - 用于身份有效但 tenant / permission / admin boundary 拒绝的场景
- `404`：
  - tenant-owned resource（租户拥有资源）要隐藏 cross-tenant existence
  - 例如 `conversation.not_found`、`media.asset_not_found`
- `409`：
  - `routing.assignment_conflict`
  - `conflict.idempotency_payload_mismatch`
  - `conflict.version_mismatch`
  - 用于 state conflict / idempotency / optimistic concurrency failure（状态冲突 / 幂等 / 乐观并发失败）
- `503` / `5xx`：
  - `search.degraded_unavailable`
  - `ai.policy_load_failed`
  - `<service>.internal_error`
  - 用于 dependency degraded、upstream unavailable 或 unexpected internal failure
- internal event consumer（内部事件消费者）在 `tenant_id` 缺失或 producer 不可信时，不确认成功，不产生业务副作用。

## Idempotency Rules（幂等规则）
- 以下接口必须要求 `Idempotency-Key`：
  - `POST /v1/conversations/{conversation_id}/messages`
  - `POST /v1/conversations/{conversation_id}:assign`
  - `POST /v1/conversations/{conversation_id}:transfer`
  - `POST /v1/ai/decisions:execute`
  - `POST /v1/assets`
- 幂等命名域（idempotency namespace）由以下元素组成：
  - `tenant_id`
  - route template
  - actor identity（操作者身份）
  - `Idempotency-Key`
- 如果相同 key 对应的 payload 不一致，返回 `409 conflict.idempotency_payload_mismatch`。

## Optimistic Concurrency Rules（乐观并发规则）
- versioned config resources（带版本的配置资源）必须暴露 `version`。
- mutation 请求必须携带 `If-Match: W/"<version>"`。
- 适用资源（applicable resources）包括：
  - `InterventionRule`
  - `ResponseTimeoutPolicy`
  - `AssetItem` review transition
  - 如果未来暴露 AI policy snapshot publish / rollback 写接口，也必须遵守同一规则

## Error Envelope（错误信封）
- 统一错误 envelope 定义见 `schemas/error-envelope.schema.json`。
- 固定字段包括：
  - `code`
  - `message`
  - `category`
  - `error_source`
  - `retryable`
  - `correlation_id`
  - `details`
  - `violations`
- 这个 envelope 不增加 inner status（内层状态码）或 outer success wrapper（外层成功包装）；operator/public surfaces 出错时直接配合真实 HTTP status 使用。
- 错误码命名规则是 `<domain>.<reason>`，并且要明确区分 gateway 与 system：
  - `gateway.*` 只保留给 edge / gateway 在请求进入 owning service（拥有该资源的服务）之前就能判定的失败
  - system-side failures（系统侧失败）必须使用 owning service 或 cross-cutting domain 前缀，不能复用 `gateway.*`
- `error_source` 语义固定为：
  - `gateway`：错误发生在 API gateway / edge boundary / tenant resolution 前置阶段
  - `system`：错误发生在 owning service、domain policy、依赖访问或内部处理阶段
- 典型示例：
  - `gateway.request_invalid`
  - `gateway.identity_invalid`
  - `gateway.tenant_context_missing`
  - `gateway.admin_surface_required`
  - `conversation.invalid_request`
  - `conversation.permission_denied`
  - `routing.assignment_conflict`
  - `tenant.forbidden_cross_tenant`
  - `tenant.channel_binding_mismatch`
  - `tenant.untrusted_event_producer`
  - `conversation.not_found`
  - `search.degraded_unavailable`
  - `ai.policy_load_failed`
  - `conflict.idempotency_payload_mismatch`

## Paging And Replay（分页与重放）
- 普通列表接口：
  - 输入：`page_size`, `page_token`
  - 输出：`next_page_token`
- 搜索接口：
  - 输入：`page_size`, `search_after`
  - 输出：`next_search_after`
- realtime replay：
  - 输入：`last_seen_sequence`
  - 输出：从下一个 `sequence` 开始的 committed messages（已提交消息）
- `message_id + sequence` 是 UI 与 gateway 共同使用的幂等应用键。

## Event Envelope（事件信封）
- 统一 event envelope 定义见 `schemas/event-envelope.schema.json`。
- 必备字段（required fields）包括：
  - `event_id`
  - `event_type`
  - `tenant_id`
  - `occurred_at`
  - `correlation_id`
  - `producer`
  - `payload_version`
  - `payload`
- 统一规则：
  - producer 只能发布自己拥有的事实
  - consumer 必须容忍 at-least-once replay
  - 事件载荷新增 optional 字段属于 additive
  - 删除、重命名、必填化、语义改变都属于 breaking

## Compatibility Policy（兼容性策略）
- additive（增量兼容）包括：
  - 新增 optional field
  - 新增 enum value，且 consumer 已声明 tolerant parsing（宽容解析）
  - 新增 response field，且旧 consumer 可以忽略
- breaking（破坏性变更）包括：
  - 删除 field
  - 重命名 field
  - optional 变 required
  - 改变 field type / format / semantic meaning
  - 改变 replay 或 idempotency meaning
  - 把 operator/public non-`2xx` error 改成 `200` success envelope
  - 让既有 `GET` surface 开始接受 request body
- 发生 breaking change 时，必须：
  - 更新相关 ADR
  - 添加 migration notes（迁移说明）
  - 更新 examples 与 negative cases

## Review Checklist（评审清单）
- 这个 surface（接口面）是否依赖 trusted `TenantContext`，而不是客户端自报租户？
- 这个 surface 是否标清了 `x-required-permissions`，而不是从前端按钮或角色名隐式推断权限？
- 这个 surface 是否错误地允许 `platform_admin` 复用 tenant-scoped operator API？
- 这个 surface 是否错误地允许 `GET` request body 进入业务语义？
- 这个 surface 是否把真实失败包装成 outer `200` success envelope？
- 是否明确声明 `Idempotency-Key` 要求？
- 是否复用了统一错误 envelope？
- 是否使用了正确的 paging / replay primitive（基础机制）？
- 是否标清了 owner、consumer、versioning 和 compatibility notes？

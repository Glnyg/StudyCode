# Shared Contract Core（共享合同核心）

## Trusted Request Context（可信请求上下文）
- 客户端可以直接提供的字段只包括：
  - `Authorization`
  - `X-Correlation-Id`
  - `traceparent`
  - `tracestate`
  - `Idempotency-Key`
  - `If-Match`
- `tenant_id` 不能作为可直接信任的客户端 header 出现。
- 服务在进入业务处理前，必须构造 trusted `TenantContext`（可信租户上下文）：
  - operator console 请求：来自 token claims + tenant-scoped RBAC
  - channel webhook：来自 verified channel binding
  - internal event：来自 trusted event envelope
- `TenantContext`、`UserContext`、`ConversationContext`、`AttachmentRef`、`AssetItem`、`AiDecisionContext`、`AuditEnvelope` 的冻结形状见 `schemas/shared-types.schema.json`。

## Header And Context Rules（Header 与上下文规则）

| Header | 是否必需 | 含义 | 合同规则 |
| --- | --- | --- | --- |
| `Authorization` | operator APIs 必需 | bearer token | 缺失或 tenant 不匹配时必须 fail closed |
| `X-Correlation-Id` | 入站推荐、响应中必须回显 | request correlation（请求关联） | 如果缺失由服务生成，并写入 response / event envelope |
| `traceparent` | 推荐 | distributed tracing（分布式追踪） | 透传到下游与异步 event |
| `tracestate` | 可选 | vendor trace state（供应商追踪状态） | 原样透传 |
| `Idempotency-Key` | 下列 side-effecting `POST` 必需 | dedupe for retried intent（重试意图去重） | 相同 key + same tenant + same route 必须返回相同语义结果 |
| `If-Match` | versioned config writes 必需 | optimistic concurrency（乐观并发） | mismatch 返回 `409` |

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
  - `retryable`
  - `correlation_id`
  - `details`
  - `violations`
- 错误码命名规则是 `<domain>.<reason>`，例如：
  - `tenant.context_missing`
  - `tenant.forbidden_cross_tenant`
  - `conversation.not_found`
  - `routing.assignment_conflict`
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
- 发生 breaking change 时，必须：
  - 更新相关 ADR
  - 添加 migration notes（迁移说明）
  - 更新 examples 与 negative cases

## Review Checklist（评审清单）
- 这个 surface（接口面）是否依赖 trusted `TenantContext`，而不是客户端自报租户？
- 是否明确声明 `Idempotency-Key` 要求？
- 是否复用了统一错误 envelope？
- 是否使用了正确的 paging / replay primitive（基础机制）？
- 是否标清了 owner、consumer、versioning 和 compatibility notes？

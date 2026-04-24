# Contract Gap Audit And Workstreams（合同缺口审计与并行工作流）

## Current State（当前状态）

| 来源 | 当前优势 | 当前缺口 |
| --- | --- | --- |
| `docs/api/public-contracts-and-events.md` | 已列出 API family、event catalog、部分 payload 示例 | 仍缺 machine-readable schema、错误码规范、兼容性分类、负例、分页 / 幂等 / 并发规则 |
| `docs/domain/*` | 已冻结租户、会话、告警、媒体、AI 的业务边界 | 合同层还没有把这些规则落成统一 request / response / event 字段 |
| `docs/reliability/power-loss-and-recovery.md` | 已冻结 `message_id + sequence`、ack-after-commit、replay-safe | 还没有进入可生成 DTO / contract tests 的正式合同文件 |
| `docs/search/chat-history-search.md` | 已定义 filters、`search_after`、degraded-search | 还没落到 `OpenAPI` 与错误 envelope |
| `docs/ai/ai-service-design.md` | 已定义 mode、tool policy、fallback、audit | 还没落到具体 API / enum / payload schema |

## Gap Summary（缺口总结）
- 缺少统一的 request context（请求上下文）规范：
  - `Authorization`
  - `X-Correlation-Id`
  - `traceparent`
  - `tracestate`
  - `Idempotency-Key`
  - `If-Match`
- 缺少统一 error envelope（错误信封）和错误码命名规范。
- 缺少统一 cursor、`search_after`、`last_seen_sequence` 语义。
- 缺少 event envelope（事件信封）与 payload versioning（载荷版本）的 machine-readable 定义。
- 缺少每个服务的 negative cases、compatibility notes 和 contract-test baseline。

## Owner / Consumer Matrix（Owner / Consumer 矩阵）

| Producer / Owner | 接口面 | 主要 consumers | 说明 |
| --- | --- | --- | --- |
| `api-gateway` | HTTP headers、auth forwarding、trace propagation | operator console、downstream services | 只冻结最小边界，不扩展业务 API |
| `conversation-service` | conversations list、replay、send、evaluate、conversation events | `routing-service`、`search-service`、`ai-service`、`realtime-gateway` | 这是 `search` / `routing` / `ai` 的上游合同 |
| `realtime-gateway` | SignalR connect / subscribe / replay / ack | operator console | 依赖 `conversation-service` 的 `sequence` 语义 |
| `routing-service` | queue / assignment / transfer / presence / alerting APIs 与事件 | operator console、analytics consumers、`realtime-gateway` | 依赖 conversation 事件中的 assignment / replay 关键字段 |
| `search-service` | message search / autocomplete / health | operator console、supervisors | 依赖 conversation event shapes 冻结 |
| `media-service` | upload / review / list / preview | operator console、`ai-service` | 要与 `AssetItem` / `AttachmentRef` 保持一致 |
| `ai-service` | suggestion / execute / policy snapshot / audit | operator console、`conversation-service` | 依赖 `ConversationContext` 和 `AssetItem` 形状 |

## Workstream Packages（工作流包）
- `Package A / Shared Governance`
  - shared conventions
  - error catalog policy
  - event envelope
  - review checklist
- `Package B / Conversation + Realtime`
  - conversation `OpenAPI`
  - realtime edge contract
  - conversation event schemas
- `Package C / Routing + Alerting`
  - routing `OpenAPI`
  - assignment / transfer / alerting event schemas
- `Package D / Search`
  - search `OpenAPI`
  - degraded-search error policy
- `Package E / Media`
  - media `OpenAPI`
  - asset reference compatibility
- `Package F / AI`
  - AI `OpenAPI`
  - tool gating / audit / fallback schema
- `Package G / Consistency Closure`
  - index update
  - ADR
  - Obsidian mirror
  - contract-test baseline

## Dependency Order（依赖顺序）
1. `Package A`
2. `Package B`
3. `Package C` 与 `Package E`
4. `Package D` 依赖 `Package B`
5. `Package F` 依赖 `Package A`，并复用 `Package E` 的 asset shape（素材形状）
6. `Package G`

## Freeze Decisions In This Package（本包冻结决策）
- `tenant_id` 只来自 trusted resolved context（可信解析上下文），不定义可伪造的客户端租户 header。
- side-effecting `POST`（有副作用的 `POST`）必须显式声明是否要求 `Idempotency-Key`。
- versioned config mutations（带版本配置变更）使用 `If-Match` 做 optimistic concurrency（乐观并发）。
- search 只使用 `search_after`，不引入 offset paging（偏移分页）。
- realtime replay 只认 `last_seen_sequence`，不允许用 wall-clock time（墙钟时间）猜测缺失消息。
- additive contract changes（增量兼容变更）默认允许；字段移除、重命名、语义改变都视为 breaking。

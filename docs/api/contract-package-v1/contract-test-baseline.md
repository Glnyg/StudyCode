# Contract Test Baseline（合同测试基线）

## Goal（目标）
- 把 `Contract Package V1` 变成后续实现必须满足的 contract-test baseline（合同测试基线），而不是“文档写过就算结束”。

## Required Checks（必需检查）

| 合同包 | 最低合同检查要求 |
| --- | --- |
| Shared Governance | header propagation、single-tenant token claim shape、`x-required-permissions`、error envelope shape、`gateway.*` vs system code distinction、admin-surface rejection、`GET` body rejection、no outer `200 + inner error` wrapping、idempotency conflict、version-mismatch response |
| Conversation + Realtime | list / replay / send / evaluate schema validation、`Idempotency-Key` 去重、`last_seen_sequence` replay、cross-tenant `404` 行为 |
| Routing + Alerting | assign / transfer / presence schema validation、过期 `If-Match`、重复 alert 去重、跨租户 ack / resolve 拒绝 |
| Search | query schema validation、`search_after` 形状、highlight array、显式 degraded-search error |
| Media | upload / review / list / preview schema validation、asset version checks、跨租户 asset denial |
| AI | suggestion / execute / policy / audit schema validation、video handoff path、tool gating 负例、audit completeness（审计完整性） |

## Multi-Tenant Negative Cases（多租户负例）
- missing tenant context（缺少租户上下文）
- missing / invalid operator token（缺少 / 无效操作员令牌）
- forged tenant access（伪造租户访问）
- token tenant mismatch（令牌租户与资源租户不匹配）
- missing / wrong channel binding（缺少 / 错误渠道绑定）
- internal event missing trusted producer 或 `tenant_id`
- `platform_admin` 直接走 tenant-scoped operator surface
- `platform_admin` 缺少 explicit target tenant 或 audit metadata
- cross-tenant conversation read（跨租户读取会话）
- cross-tenant conversation send（跨租户发送消息）
- cross-tenant search（跨租户搜索）
- cross-tenant asset preview（跨租户预览素材）
- cross-tenant asset review（跨租户审核素材）
- cross-tenant alert ack / resolve（跨租户确认/解决告警）
- cross-tenant AI policy publish / admin misuse（跨租户 AI 策略发布或管理员误用）

## HTTP Response Strategy Cases（HTTP 响应策略场景）
- `GET` with body（携带请求体的 `GET`）必须返回真实 `400`，不能静默忽略后继续执行业务。
- operator/public command 或 CRUD failure（命令或增删改查失败）必须返回真实非 `2xx` 状态码，不能返回 outer `200 + inner error`。
- `401` 与 `403` 的 examples 必须覆盖 `gateway` 与 `system` 的 owner distinction（归属区分）。
- 所有 `gateway.*` example 都必须配 `error_source = gateway`。
- 所有 service / domain / dependency / internal example 都必须配 `error_source = system`。

## Recovery / Idempotency Cases（恢复与幂等场景）
- duplicate webhook 或 event delivery（重复投递）
- 使用同一个 `Idempotency-Key` 的 duplicate agent outbound send
- 使用同一个 dedupe tuple（去重元组）的 duplicate notification dispatch
- 面向 event schemas 的 consumer restart replay
- 按 `last_seen_sequence` 进行 websocket reconnect

## Compatibility Review Gate（兼容性评审闸门）
- additive change（增量兼容变更）：
  - 更新 schema / examples
  - 当 enum 增长时，写明 tolerant parsing expectations（宽容解析预期）
- breaking change（破坏性变更）：
  - 必须有 ADR
  - 必须有 migration notes
  - 必须更新 examples、negative cases、compatibility notes

## Done Means（完成标准）
- schema validation（Schema 校验）可以基于 `OpenAPI` / `JSON Schema` 自动执行
- examples 同时覆盖 positive cases（正例）和 negative cases
- shared docs、OpenAPI examples、error envelope schema 和 Obsidian 镜像对 `HTTP status + error_source + code` 的语义必须一致
- 后续任何实现任务都不需要自行发明缺失的 envelope、cursor、replay 或 idempotency semantics

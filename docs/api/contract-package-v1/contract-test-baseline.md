# Contract Test Baseline（合同测试基线）

## Goal（目标）
- 把 `Contract Package V1` 变成后续实现必须满足的 contract-test baseline（合同测试基线），而不是“文档写过就算结束”。

## Required Checks（必需检查）

| 合同包 | 最低合同检查要求 |
| --- | --- |
| Shared Governance | header propagation、error envelope shape、idempotency conflict、version-mismatch response |
| Conversation + Realtime | list / replay / send / evaluate schema validation、`Idempotency-Key` 去重、`last_seen_sequence` replay、cross-tenant `404` 行为 |
| Routing + Alerting | assign / transfer / presence schema validation、过期 `If-Match`、重复 alert 去重、跨租户 ack / resolve 拒绝 |
| Search | query schema validation、`search_after` 形状、highlight array、显式 degraded-search error |
| Media | upload / review / list / preview schema validation、asset version checks、跨租户 asset denial |
| AI | suggestion / execute / policy / audit schema validation、video handoff path、tool gating 负例、audit completeness（审计完整性） |

## Multi-Tenant Negative Cases（多租户负例）
- missing tenant context（缺少租户上下文）
- forged tenant access（伪造租户访问）
- cross-tenant conversation read（跨租户读取会话）
- cross-tenant search（跨租户搜索）
- cross-tenant asset preview（跨租户预览素材）
- cross-tenant alert ack / resolve（跨租户确认/解决告警）

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
- 后续任何实现任务都不需要自行发明缺失的 envelope、cursor、replay 或 idempotency semantics

# P1-01 Search Freeze Package

## Goal（目标）
冻结 `search-service` 的最终 OpenSearch mappings、index lifecycle、projection replay contract 和 rebuild 运行方式，确保搜索读侧可以在对应里程碑前以一致方式实现、重建和运维。

## Must Be Frozen By（最晚冻结时间）
在启动 `search-service` 的 projection、query path 和 rebuild tooling 实现前完成。

## Scope（范围）
- final OpenSearch mappings
- index template 与 lifecycle policy
- projection replay contract
- rebuild job API
- operational runbook

## Non-Goals（非目标）
- 不重开“是否使用 OpenSearch”这个已冻结决策。
- 不在本议题里实现完整 search-service 代码。
- 不把 PostgreSQL 文本扫描作为 degraded-search fallback（降级兜底）。

## Affected Paths（影响路径）
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/search/chat-history-search.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/search/chat-history-search.md)
- [docs/api/contract-package-v1/search-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/search-pack.md)
- [docs/api/contract-package-v1/openapi/search-service.openapi.yaml](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/openapi/search-service.openapi.yaml)

## Constraints（约束）
- search 只能作为 derived read-side（派生读侧），不能持有 transaction truth。
- query 必须强制 tenant filter，不能产生 cross-tenant hits。
- degraded-search 必须返回 explicit error（显式错误），不能 silent fallback 到 PostgreSQL 广泛文本扫描。
- rebuild 必须 replay-safe，并能从 source of truth / events 重新构建。

## Acceptance Checks（验收检查）
- 已明确最终 mapping、index template、lifecycle policy 和 rebuild contract。
- 已明确 projection replay 依赖哪些事件、如何处理 redaction、重放和重复投递。
- 已明确 rebuild job 的触发方式、输入、预期输出和最小 runbook。
- 文档与现有 search API contract、filtering、pagination、highlight 规则一致。

## References（参考）
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [chat-history-search.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/search/chat-history-search.md)
- [search-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/search-pack.md)

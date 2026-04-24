# ADR 0003：使用 OpenSearch 承载聊天搜索读侧

## Status（状态）
Accepted（已接受）

## Context（背景）
工作台（workbench）需要 fast、tenant-safe 的 search，并支持 highlight、filtering、autocomplete 和 1 年在线保留。PostgreSQL 仍然是 transactional source of truth。

## Decision（决策）
- 引入由 OpenSearch 支撑的 `search-service`，专门负责 chat history search。
- PostgreSQL FTS 只保留给低频运维兜底（operational fallback）和有针对性的 admin usage。
- Search data 通过 domain events 异步投影（project）出来。

## Consequences（影响）
- Search 会变成 eventually consistent（最终一致）。
- OpenSearch 故障时返回 explicit degraded-search errors，而不是静默 SQL 扫描。
- Search index schema 和 retention policy 升格为一等设计资产。

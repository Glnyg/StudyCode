# ADR 0002：保持 PostgreSQL 为事实源，并要求派生存储可重建

## Status（状态）
Accepted（已接受）

## Context（背景）
系统同时使用 PostgreSQL、OpenSearch、Redis、RabbitMQ 和 object storage。如果 ownership（归属）不清，derived stores（派生存储）会悄悄变成事实上的 source of truth。

## Decision（决策）
- PostgreSQL 是 transactions、audit、AI configuration、knowledge metadata 的 source of truth。
- OpenSearch、Redis 和 analytics read models 都是 derived 且 rebuildable（可重建）的。
- Services 不允许绕过 ownership boundaries，把 business truth 只写进 derived stores。

## Consequences（影响）
- search 或 analytics 的 rebuild flows 是强制要求，不是可选能力。
- incident response（事故处理）优先从 PostgreSQL 和 events 回放。
- 禁止 cross-service direct table reads（跨服务直读表）。

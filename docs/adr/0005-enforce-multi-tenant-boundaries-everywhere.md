# ADR 0005：在运行时、搜索和 AI 全面执行多租户边界

## Status（状态）
Accepted（已接受）

## Context（背景）
这是一个真实的多租户客服系统。Search projections、AI policies、media assets 和 transactional queries 一样，都可能在边界不严时泄露数据。

## Decision（决策）
- `tenant_id` 在 requests、events、caches、search documents、object keys、AI decisions 中都是 mandatory（必填）的。
- 缺少 tenant context 时必须 fail closed。
- 生产环境不允许有 default tenant 行为。

## Consequences（影响）
- 每个 search query 和每次 knowledge retrieval 都必须做 tenant filtering。
- shared infrastructure（共享基础设施）不等于 shared data visibility（共享数据可见性）。
- transactional、search、AI flows 都必须有 cross-tenant tests。

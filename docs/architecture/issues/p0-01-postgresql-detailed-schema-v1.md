# P0-01 PostgreSQL Detailed Schema V1

## Goal（目标）
冻结所有 source-of-truth services（事实源服务）的 PostgreSQL 详细数据模型，确保后续 migrations、repositories、outbox/inbox、replay 和 audit 实现不需要现场发明核心字段或顺序语义。

## Why This Blocks Coding（为什么阻塞编码）
- `conversation-service`、`routing-service` 等核心服务的实现依赖表结构、唯一键、索引、幂等键和 replay 顺序规则。
- 如果 schema freeze（模式冻结）缺失，编码会直接把不变量埋进实现细节，后续难以统一修正。
- 首个里程碑当前最实质的 blocker（阻塞项）就是 `message`、`conversation`、`outbox`、replay schema 仍未冻结。

## Scope（范围）
- `conversation-service`
- `routing-service`
- `identity-service`
- `knowledge-service`
- 其他持有 source-of-truth PostgreSQL tables 的服务

本议题至少要冻结：
- 逐表 logical schema（逻辑表结构）
- primary keys、tenant-scoped unique keys、foreign-key strategy（如适用）
- time partition rules（时间分区规则）和 hot-query indexes（热点查询索引）
- idempotency keys、dedupe namespace（去重命名域）和 payload mismatch 处理语义
- `message_id`、`sequence`、replay cursor、committed ordering（提交顺序）
- audit columns、redaction markers、actor metadata
- outbox / inbox schema、consumer checkpoints、replay-safe 约束
- retention / archive hooks（保留与归档钩子）

## Non-Goals（非目标）
- 不在本议题里实现 migrations 或 repository 代码。
- 不重开 `.NET 10`、OpenSearch、RabbitMQ、Redis 等已冻结的一阶架构决策。
- 不在本议题里补齐 channel/provider 上游协议细节；那属于 `Upstream Integration Specs V1`。

## Affected Paths（影响路径）
- [docs/architecture/implementation-readiness-and-design-freeze.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-readiness-and-design-freeze.md)
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/data/storage-and-retention.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/data/storage-and-retention.md)
- [docs/reliability/power-loss-and-recovery.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/reliability/power-loss-and-recovery.md)
- 预期新增的 schema freeze 文档或其等价权威文档

## Constraints（约束）
- 必须保持 multi-tenant fail-closed（租户缺失即拒绝）和 cross-tenant isolation（跨租户隔离）。
- 必须符合 ack-after-commit、at-least-once delivery、replay-safe 和 idempotency 规则。
- 不允许把 Redis、OpenSearch 或 object storage 当成 source of truth。
- 任何 source-of-truth rule change 后续都必须能写出 domain / integration tests 来保护。

## Suggested Delivery Order（建议顺序）
1. 先冻结 `conversation-service` 的 `message` / `conversation` / `outbox` / replay schema。
2. 再冻结 `routing-service` 的 assignment、transfer、alert lifecycle 相关 schema。
3. 然后补其他 source-of-truth services 的详细数据模型。

## Acceptance Checks（验收检查）
- 已形成权威文档，能逐项回答每个核心服务“表怎么建、怎么唯一、怎么重放、怎么审计、怎么归档”。
- `conversation-service` 的 `message_id`、`sequence`、outbox 和 replay schema 已冻结到可直接写 migration 的粒度。
- 至少列出所有核心表的主键、唯一键、索引和幂等键策略。
- 至少列出 outbox / inbox 与 consumer checkpoint 的最小字段集和约束。
- 权威文档与现有 recovery、retention、tenant 规则一致，不依赖聊天记忆补规则。

## References（参考）
- [implementation-readiness-and-design-freeze.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-readiness-and-design-freeze.md)
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [storage-and-retention.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/data/storage-and-retention.md)
- [power-loss-and-recovery.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/reliability/power-loss-and-recovery.md)

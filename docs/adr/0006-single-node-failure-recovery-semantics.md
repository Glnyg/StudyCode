# ADR 0006：定义单服务与单节点故障的恢复语义

## Status（状态）
Accepted（已接受）

## Context（背景）
系统必须在单个 service 或单个 worker-node 故障时，仍然不丢失已经 acknowledged 的聊天消息。仅靠 Kubernetes restart behavior 并不能保证 durability 或 consistency。

## Decision（决策）
- 已 acknowledged 的 inbound messages 在向上游返回成功前，必须已经 durable 到 PostgreSQL。
- 关键 domain events 使用 RabbitMQ durable quorum queues，并启用 publisher confirms。
- Consumers 必须 idempotent 且 replay-safe。
- Realtime delivery 允许按 message sequence reconnect 和 replay，但它不拥有 business truth。
- Redis 可以丢失 ephemeral state，而不违反 durability guarantee（持久性保证）。

## Consequences（影响）
- Outbox / inbox 和 replay logic 是 mandatory（必需项），不是 optional（可选项）。
- Stateless services 在生产上至少需要两个 replicas。
- Recovery behavior 成为正式合同的一部分，必须通过 failure drills（故障演练）验证。

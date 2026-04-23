# ADR 0006: Define Recovery Semantics For Single Service And Single Node Failure

## Status
Accepted

## Context
The system must survive single service or single worker-node failures without losing already acknowledged chat messages. Kubernetes restart behavior alone is not sufficient to guarantee durability or consistency.

## Decision
- Acknowledged inbound messages must be durable in PostgreSQL before success is returned upstream.
- Critical domain events use RabbitMQ durable quorum queues plus publisher confirms.
- Consumers must be idempotent and replay-safe.
- Realtime delivery may reconnect and replay by message sequence; it does not own business truth.
- Redis may lose ephemeral state without violating the durability guarantee.

## Consequences
- Outbox/inbox and replay logic are mandatory, not optional.
- Stateless services require at least two production replicas.
- Recovery behavior becomes part of the formal contract and must be covered by failure drills.

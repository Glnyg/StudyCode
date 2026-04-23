# Power Loss And Recovery

## Goal
Guarantee that a single stateless service instance failure or a single Kubernetes worker-node power loss does not lose already acknowledged chat messages and that the main chat flow resumes automatically after restart or rescheduling.

## In Scope
- Single application Pod crash
- Single Kubernetes worker node power loss
- Single realtime gateway instance loss
- Single RabbitMQ node loss when quorum queues remain healthy
- PostgreSQL primary instance loss when HA failover is healthy

## Out Of Scope
- Entire cluster power loss
- Region or data-center outage
- Permanent multi-disk corruption across replicas
- Upstream provider behavior that is not idempotent and offers no dedupe key

## Recovery Semantics
- If the system has acknowledged an inbound message, that message must already be durable in PostgreSQL source-of-truth storage.
- Realtime pushes may be interrupted during failure, but the client must recover by reconnecting and replaying missed messages from source truth.
- Search, analytics, and AI side lanes may lag or replay after recovery; they must not block chat truth.
- No retry path may create duplicate business side effects after restart.

## Component Requirements

### Stateless Services
- All hot-path stateless services must run with at least `2` replicas in production.
- Replicas must be spread across nodes using anti-affinity or topology spread constraints.
- Readiness and liveness probes are mandatory.
- Pod restart must not require manual operator intervention to resume normal traffic.

### PostgreSQL
- PostgreSQL is the only source of truth for acknowledged messages and conversation state.
- Production requires HA failover, durable storage, WAL persistence, and automated primary promotion.
- Acknowledge inbound message success only after the local transaction that writes:
  - `message_log`
  - `conversation_event` when applicable
  - `outbox_message`
  has committed successfully.
- Recovery may replay outbox delivery, but must not duplicate source-of-truth messages.

### RabbitMQ
- Use durable queues and `quorum queues` for critical domain events.
- Producers must use publisher confirms.
- Consumers must acknowledge only after their idempotent local transaction commits.
- Replayed deliveries after restart are expected and must be safe.

### Redis
- Redis may lose transient state without violating message durability guarantees.
- Presence, websocket grouping hints, and short idempotency windows may be rebuilt after restart.
- Redis must never be the sole owner of message, routing, or audit truth.

### Object Storage
- Media files and fixed assets must be written to durable object storage before any downstream flow depends on them.
- Metadata and object keys are source-of-truth in owned databases; media processing may replay if the file already exists.

## Main Flow Rules

### Inbound Customer Message
1. `channel-service` verifies and normalizes the inbound request.
2. `conversation-service` writes the message transactionally to PostgreSQL and writes an outbox record in the same transaction.
3. Only after commit may the system return success to the upstream channel.
4. An outbox relayer publishes the domain event to RabbitMQ with publisher confirm.
5. `realtime-gateway`, `search-service`, `ai-service`, and `analytics-service` consume asynchronously.

### Agent Outbound Message
1. Agent send request creates a durable outbound intent record in PostgreSQL before any upstream call.
2. `channel-service` sends upstream using an idempotency key or provider-supported dedupe field.
3. If crash happens after durable intent but before upstream confirmation, recovery retries the same intent.
4. If upstream confirms but local status update fails, reconciliation must detect and complete the final state without duplicating customer-visible sends where the provider supports idempotency.

## Reconnect And Replay
- Every conversation message carries a monotonic `sequence`.
- Clients track `last_seen_sequence` per conversation.
- After websocket reconnect, client requests replay from the last confirmed sequence.
- Realtime delivery is therefore allowed to be at-least-once; UI application must be idempotent by `message_id` and `sequence`.

## Recovery By Failure Type

### Single Application Pod Crash
- Kubernetes restarts or reschedules the Pod.
- Any unacked request is retried by caller or upstream webhook.
- Any acked message remains in PostgreSQL and can be replayed.

### Single Worker Node Power Loss
- Pods on the failed node are recreated elsewhere.
- Hot path continues if there is at least one healthy replica for each required stateless service.
- Clients reconnect to healthy realtime gateways and replay missed messages.

### Realtime Gateway Loss
- Connections drop temporarily.
- No business truth is lost.
- Reconnect + replay restores the visible conversation state.

### Search Or AI Worker Loss
- Chat truth and routing continue.
- Search indexing and AI side effects replay from RabbitMQ or source truth after worker recovery.

## Forbidden Patterns
- Acknowledge inbound success before PostgreSQL commit.
- Rely on Redis for the only copy of business state.
- Let OpenSearch act as replay truth after restart.
- Consume RabbitMQ messages without idempotent handling.
- Use silent “best effort” outbound retries that can duplicate customer-visible side effects.

## Verification Requirements
- Power-off drill for a stateless service node while live chat traffic is running.
- Power-off drill for a realtime gateway node during active sessions.
- Restart drill for a RabbitMQ consumer with duplicate delivery replay.
- Replay drill where websocket clients reconnect and recover missed messages by sequence.
- Failover drill for PostgreSQL primary without losing already acknowledged inbound messages.

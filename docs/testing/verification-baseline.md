# Verification Baseline

## Architecture Acceptance
- Service boundaries are documented and unambiguous.
- Source-of-truth stores and derived stores are clearly separated.
- Every public contract and domain event is documented.

## Multi-Tenant Checks
- Missing tenant fails closed.
- Forged tenant access fails closed.
- Cross-tenant search fails closed.
- Cross-tenant asset or knowledge access fails closed.

## Search Checks
- keyword search
- highlight rendering
- time filtering
- customer/agent/channel/queue filtering
- pagination with stable ordering
- delayed projection consistency
- explicit degraded-search error when OpenSearch is down

## Realtime Checks
- `p95 < 800ms` ingress-to-push
- `p99 < 2s` ingress-to-push
- 200+ online agents
- queue transfer and assist actions preserve ordering and audit

## AI Checks
- text request path
- text + image request path
- video always routes to human
- fixed asset selection only
- low-risk tool policy gating
- configuration publish and rollback traceability
- conversation-level AI replay

## Intervention Checks
- configured keyword hit triggers urgent intervention
- non-matching text does not trigger
- cooldown window prevents duplicate alerts for the same conversation and rule
- device enrichment timeout still sends the notification with explicit fallback state
- acknowledgement and resolution are auditable
- Enterprise WeChat or Feishu provider failure does not block chat flow

## Failure Drills
- RabbitMQ single node loss
- Redis transient instability
- OpenSearch node loss
- PostgreSQL failover
- realtime gateway rollout
- search projection rebuild
- single stateless service Pod crash during live chat
- single worker-node power loss during live chat
- websocket reconnect plus replay by sequence
- outbound retry after worker restart with no duplicate visible side effect

## Data Checks
- PostgreSQL partition pruning works for time-bound chat queries.
- OpenSearch retention policies align to 365-day online target.
- Search hit links always replay the correct source-of-truth conversation.

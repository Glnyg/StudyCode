# ADR 0009: Response Timeout Alerting Stays As A Routing-Owned Side Lane

## Status
Accepted

## Context
The system needs to support tenant-configured alerts for assigned human conversations where the customer has waited longer than a configured number of minutes without a human reply. These alerts need to notify management channels like Enterprise WeChat or Feishu and may include optional device enrichment, but they must not block inbound chat durability or realtime agent delivery.

Possible placements included:
- `conversation-service`
- `routing-service`
- a new dedicated `notification-service`
- external cron or observability tooling

## Decision
- Keep response timeout alerting as a `routing-service` owned capability.
- Trigger it asynchronously from committed `MessageAppended`, `ConversationAssigned`, `TransferCompleted`, and `ConversationClosed` facts after source-of-truth commit.
- Keep `ResponseTimeoutPolicy` and `ResponseTimeoutAlert` as separate models from `UrgentIntervention`.
- Resolve timeout policy by tenant default plus exact queue override.
- Allow optional device enrichment through `device-service`.
- Dispatch management notifications through provider adapters or workers owned by `routing-service`.
- Do not introduce a dedicated `notification-service` unless provider scope or throughput later justifies a split.

## Consequences
- the hot chat path remains unchanged
- response-timeout policy, waiting-window state, and management notification orchestration stay in one control-domain service
- timeout alerts and keyword interventions can share notification adapters without sharing lifecycle semantics
- notification failures do not corrupt conversation truth
- future expansion to repeated reminders or escalations remains possible without moving message truth or routing ownership

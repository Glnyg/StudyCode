# ADR 0008: Urgent Intervention Stays As A Routing-Owned Side Lane

## Status
Accepted

## Context
The system needs to support tenant-configured high-risk keyword detection, such as complaint or regulator-related terms, and notify management channels like Enterprise WeChat or Feishu for urgent intervention. This capability must not block inbound chat durability or realtime agent delivery.

Possible placements included:
- `ai-service`
- `analytics-service`
- a new dedicated `notification-service`
- `routing-service`

## Decision
- Keep urgent intervention as a `routing-service` owned capability.
- Trigger it asynchronously from `MessageAppended` after source-of-truth commit.
- Use deterministic keyword or phrase rules as the primary V1 trigger.
- Allow optional device enrichment through `device-service`.
- Dispatch management notifications through provider adapters or workers owned by `routing-service`.
- Do not introduce a dedicated `notification-service` unless notification-provider scope or throughput later justifies a split.

## Consequences
- the hot chat path remains unchanged
- urgent intervention, queue priority, supervisor visibility, and acknowledgement stay in one control-domain service
- notification failures do not corrupt conversation truth
- future evolution to AI-assisted classification remains possible without moving message truth or routing ownership

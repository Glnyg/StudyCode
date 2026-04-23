# Urgent Intervention And Management Alerting

## Goal
Provide a deterministic, tenant-safe way to detect configured high-risk conversation content such as complaint keywords and trigger urgent manager intervention without blocking the main chat path.

## Scope For V1
- detect tenant-configured keywords or phrases in inbound customer text messages
- create an auditable urgent-intervention record
- optionally enrich the alert with device information from trusted business facts
- send internal notifications to management channels such as Enterprise WeChat or Feishu
- allow manager acknowledgement and follow-up in the console

## Explicit Non-Goals For V1
- no AI semantic classifier as the primary trigger mechanism
- no image OCR, video ASR, or video understanding for alert matching
- no direct customer-facing automatic reply from the alert flow
- no requirement for a dedicated `notification-service` on day one

## Design Principles
- urgent intervention is a side-lane workflow, not part of the realtime chat hot path
- message durability and agent push happen first; alerting reacts after source-of-truth commit
- deterministic rules come before AI heuristics
- device enrichment is optional and bounded by timeout
- notifications are best-effort with retry, but alert creation and audit must be durable

## Ownership
- `conversation-service` owns source-of-truth messages and emits `MessageAppended`
- `routing-service` owns:
  - intervention rule evaluation
  - intervention state
  - cooldown and dedupe
  - acknowledgement workflow
  - management notification dispatch orchestration
- `device-service` provides optional device/order enrichment
- `analytics-service` may project intervention KPIs but does not trigger alerts
- `channel-service` does not own internal management notifications

## Runtime Flow
1. `conversation-service` commits the inbound message and outbox event.
2. `routing-service` consumes `MessageAppended` asynchronously.
3. The intervention evaluator checks tenant-scoped rules for the message.
4. If a rule matches, `routing-service` creates or reuses an `UrgentIntervention` record transactionally.
5. If configured, `routing-service` requests a bounded device snapshot from `device-service`.
6. `routing-service` emits `UrgentInterventionTriggered`.
7. A notification worker dispatches Enterprise WeChat or Feishu alerts and records delivery attempts.
8. Managers acknowledge or resolve the intervention from the console.

## Matching Rules
- V1 evaluates only normalized text messages from customers.
- V1 rule operators:
  - `contains_any`
  - `contains_all`
- V1 does not support arbitrary regex by default.
- Rules may be scoped by:
  - `tenant_id`
  - channel
  - queue
  - conversation mode
  - severity
- Matching input comes from source-of-truth message text, not model-generated interpretation.

## Core Entities

### `InterventionRule`
- `tenant_id`
- `rule_id`
- `name`
- `enabled`
- `severity`
- `match_operator`
- `terms`
- `channel_scope`
- `queue_scope`
- `cooldown_window`
- `notify_policy_id`
- `enrichment_policy`
- `auto_actions`
- `version`

### `UrgentIntervention`
- `tenant_id`
- `intervention_id`
- `conversation_id`
- `trigger_message_id`
- `rule_id`
- `severity`
- `matched_terms`
- `status`
- `dedupe_key`
- `triggered_at`
- `last_matched_at`
- `ack_actor_id`
- `acked_at`
- `resolved_at`

### `NotificationEndpoint`
- `tenant_id`
- `endpoint_id`
- `provider_type`
- `channel_name`
- `secret_ref`
- `template_id`
- `enabled`
- `version`

### `NotificationDelivery`
- `tenant_id`
- `delivery_id`
- `intervention_id`
- `endpoint_id`
- `template_version`
- `enrichment_status`
- `status`
- `attempt_count`
- `last_error_code`
- `last_error_message`
- `last_attempted_at`
- `delivered_at`

## Notification Payload Rules
- payload may include:
  - tenant display name
  - conversation id or console deep link
  - severity
  - matched terms
  - redacted message excerpt
  - channel
  - queue
  - device snapshot when available
  - trigger time
- payload must not include:
  - secrets or tokens
  - raw provider credentials
  - unnecessary customer PII
  - full conversation transcript by default

## Device Enrichment Rules
- enrichment uses trusted identifiers already attached to conversation or message context
- `routing-service` may call `device-service` only after intervention creation
- enrichment timeout must not block notification indefinitely
- if enrichment fails or times out:
  - notification still sends
  - delivery audit records `enrichment_status`
  - no hidden retry loop is allowed inside the synchronous dispatch path

## Cooldown And Idempotency Rules
- duplicate `MessageAppended` deliveries must not create duplicate interventions
- within the configured cooldown window, repeated matches for the same rule and conversation reuse the active intervention record
- notification dispatch must be idempotent by `intervention_id + endpoint_id + template_version`
- all intervention events and deliveries must be replay-safe after consumer restart

## Operational Behavior
- notification provider failure must not roll back the intervention record
- failed notifications retry asynchronously with explicit status transitions
- permanent failure must remain visible in console and audit
- this workflow may lag during partial outage, but it must not delay chat persistence or realtime push

## Recommended Auto Actions
- add an `urgent_intervention` tag
- raise queue priority or flag supervisor visibility
- optionally assign a follow-up task to a management queue

Do not auto-transfer the conversation by default unless tenant policy explicitly enables it.

## Future Extensions
- AI-assisted semantic risk classification as a supplemental signal
- OCR or ASR side-lane enrichment
- a dedicated `notification-service` only if provider count, template complexity, or notification throughput justifies the split

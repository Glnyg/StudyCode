# Response Timeout Alerting

## Goal
Provide a deterministic, tenant-safe way to detect assigned human conversations where the customer has waited longer than a configured number of minutes without a human agent reply, and notify internal management channels without blocking the main chat path.

## Scope For V1
- detect customer-wait windows only for conversations with an active human assignment
- configure timeout minutes per tenant with optional exact queue overrides
- create an auditable response-timeout alert record
- optionally enrich the alert with device information from trusted business facts
- send internal notifications to management channels such as Enterprise WeChat or Feishu
- clear the waiting window when a human-visible agent reply, transfer, or conversation close changes the state

## Explicit Non-Goals For V1
- no queue-wait alerting before a human agent is assigned
- no repeated reminder cadence or escalation ladder after the first timeout notification
- no reuse of `UrgentIntervention` acknowledgement or resolution workflow
- no requirement for a dedicated `notification-service` on day one

## Design Principles
- response timeout alerting is a routing-owned side lane, not part of the realtime chat hot path
- customer message durability and agent push happen first; timeout evaluation reacts after source-of-truth commit
- timers are deterministic and derived from committed messages plus trusted assignment facts
- device enrichment is optional and bounded by timeout
- notifications are best-effort with retry, but alert creation and clear audit must be durable

## Ownership
- `conversation-service` owns source-of-truth messages and emits `MessageAppended`
- `routing-service` owns:
  - policy resolution
  - waiting-window state
  - timeout alert lifecycle
  - dedupe and replay safety
  - management notification dispatch orchestration
- `device-service` provides optional device/order enrichment
- `analytics-service` may project timeout KPIs but does not trigger alerts
- `channel-service` does not own internal management notifications

## Policy Resolution
- V1 policy lookup order:
  1. enabled exact queue match for the tenant
  2. enabled tenant default policy with no `queue_scope`
- V1 must reject configurations where multiple enabled policies could match the same tenant and queue
- if no policy matches, no timeout window is created

## Timer Semantics
- V1 applies only to conversations with an active human assignment
- when a customer message commits, `routing-service` creates or refreshes a waiting window using:
  - `waiting_started_at = max(customer_message_committed_at, assignment_effective_at)`
  - `due_at = waiting_started_at + timeout_minutes`
- the first human-visible agent outbound message clears the active waiting window
- AI draft generation, AI suggestions, internal notes, and hidden workflow messages do not clear the window
- `ConversationAssigned` or `TransferCompleted` clears the old waiting window and starts a fresh timer for the new assignee from the new assignment effective time
- `ConversationClosed` clears any pending waiting window; already-triggered alerts stay auditable with an explicit `clear_reason`

## Runtime Flow
1. `conversation-service` commits the customer message and outbox event.
2. `routing-service` consumes `MessageAppended` asynchronously.
3. `routing-service` resolves the tenant-scoped timeout policy for the active assignment and queue.
4. If a policy matches, `routing-service` creates or updates a pending waiting window and due time transactionally.
5. A timeout worker scans due windows and re-validates that the conversation is still waiting on the same assignment.
6. If still due, `routing-service` creates a `ResponseTimeoutAlert` record and emits `ResponseTimeoutAlertTriggered`.
7. If configured, `routing-service` requests a bounded device snapshot from `device-service`.
8. A notification worker dispatches Enterprise WeChat or Feishu alerts and records delivery attempts.
9. Later human reply, transfer, or conversation close clears the active waiting state and emits `ResponseTimeoutAlertCleared` when appropriate.

## Core Entities

### `ResponseTimeoutPolicy`
- `tenant_id`
- `policy_id`
- `enabled`
- `queue_scope`
- `timeout_minutes`
- `notify_policy_id`
- `device_enrichment_policy`
- `version`

### `ResponseTimeoutAlert`
- `tenant_id`
- `alert_id`
- `conversation_id`
- `waiting_message_id`
- `assignment_id`
- `agent_id`
- `queue_id`
- `policy_id`
- `status`
- `waiting_started_at`
- `due_at`
- `triggered_at`
- `cleared_at`
- `clear_reason`
- `enrichment_status`
- `dedupe_key`

This workflow reuses `NotificationEndpoint` and `NotificationDelivery` from urgent intervention notification dispatch. Timeout alert notifications set `source_type = response_timeout` and `source_id = alert_id`.

## Notification Payload Rules
- payload may include:
  - tenant display name
  - conversation id or console deep link
  - assigned agent display name and internal id
  - queue
  - waiting duration
  - device snapshot when available
  - trigger time
- payload must not include:
  - secrets or tokens
  - raw provider credentials
  - unnecessary customer PII
  - full conversation transcript by default

## Device Enrichment Rules
- enrichment uses trusted identifiers already attached to conversation or message context
- `routing-service` may call `device-service` only after timeout alert creation
- enrichment timeout must not block notification indefinitely
- if enrichment fails or times out:
  - notification still sends
  - delivery audit records `enrichment_status`
  - no hidden retry loop is allowed inside the synchronous dispatch path

## Idempotency And Recovery Rules
- duplicate `MessageAppended`, `ConversationAssigned`, or `TransferCompleted` deliveries must not create duplicate waiting windows or alerts
- alert dedupe key is `tenant_id + waiting_message_id + assignment_id`
- timeout dispatch must emit at most one external reminder per waiting round
- management notification dispatch must be idempotent by `source_type + source_id + endpoint_id + template_version`
- all waiting windows, alerts, and deliveries must be replay-safe after consumer or worker restart

## Operational Behavior
- notification provider failure must not roll back the timeout alert record
- failed notifications retry asynchronously with explicit status transitions
- permanent failure must remain visible in console and audit
- this workflow may lag during partial outage, but it must not delay chat persistence or realtime push

## Future Extensions
- repeated reminder cadence or escalation ladder
- queue-wait alerting before assignment
- supervisor auto actions such as queue escalation
- a dedicated `notification-service` only if provider count, template complexity, or notification throughput justifies the split

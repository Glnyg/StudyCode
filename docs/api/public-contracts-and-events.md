# Public Contracts And Events

## API Families

### `api-gateway`
- tenant-aware frontend entry point
- token forwarding and coarse-grained rate limiting

### `conversation-service`
- list conversations
- replay conversation messages
- send agent message
- evaluate conversation

### `routing-service`
- list queues
- assign or transfer conversation
- update agent availability
- manage intervention rules
- manage response-timeout policies
- list urgent interventions
- list response-timeout alerts
- acknowledge or resolve intervention

### `search-service`
- search messages
- autocomplete search hints
- get search health

### `media-service`
- upload fixed assets
- review asset
- list tenant assets
- resolve preview URL

### `ai-service`
- get reply suggestion
- execute AI decision
- retrieve policy snapshot
- list AI audit records

## Standard Request Context
- `tenant_id`
- `correlation_id`
- authenticated actor identity
- channel or console origin

## Event Envelope
```json
{
  "event_id": "evt-001",
  "event_type": "MessageAppended",
  "tenant_id": "tenant-a",
  "occurred_at": "2026-04-24T09:10:11Z",
  "correlation_id": "corr-001",
  "producer": "conversation-service",
  "payload_version": 1,
  "payload": {}
}
```

## Event Catalog V1
- `MessageAppended`
- `MessageRedacted`
- `ConversationClosed`
- `ConversationTagged`
- `ConversationAssigned`
- `TransferCompleted`
- `AgentPresenceChanged`
- `AiHandoffChanged`
- `UrgentInterventionTriggered`
- `UrgentInterventionAcknowledged`
- `ResponseTimeoutAlertTriggered`
- `ResponseTimeoutAlertCleared`
- `ManagementNotificationDispatched`
- `AssetSent`
- `VideoEscalatedToHuman`
- `KnowledgeReleasePublished`
- `LowRiskToolExecuted`

## MessageAppended Payload
```json
{
  "conversation_id": "conv-1001",
  "message_id": "msg-9001",
  "sender_type": "customer",
  "message_type": "text",
  "channel": "wechat_customer_service",
  "queue_id": "after_sales",
  "search_text": "请问这个套餐怎么续费",
  "has_media": false,
  "device_id": "wifi-001",
  "order_id": "order-002",
  "tags": ["package", "renewal"]
}
```

## Search API Shape
```json
POST /search/messages
{
  "tenant_id": "tenant-a",
  "q": "续费",
  "channel": "wechat_customer_service",
  "page_size": 20
}
```

## UrgentInterventionTriggered Payload
```json
{
  "intervention_id": "int-1001",
  "conversation_id": "conv-1001",
  "trigger_message_id": "msg-9001",
  "rule_id": "rule-complaint-01",
  "severity": "critical",
  "matched_terms": ["投诉", "12315"],
  "channel": "wechat_customer_service",
  "queue_id": "after_sales",
  "device_id": "wifi-001",
  "enrichment_status": "resolved"
}
```

## ResponseTimeoutAlertTriggered Payload
```json
{
  "alert_id": "rta-1001",
  "conversation_id": "conv-1001",
  "waiting_message_id": "msg-9001",
  "assignment_id": "asn-2001",
  "agent_id": "agent-001",
  "queue_id": "after_sales",
  "policy_id": "resp-after-sales",
  "waiting_started_at": "2026-04-24T09:10:11Z",
  "due_at": "2026-04-24T09:20:11Z",
  "triggered_at": "2026-04-24T09:20:16Z",
  "device_id": "wifi-001",
  "enrichment_status": "resolved"
}
```

## ResponseTimeoutAlertCleared Payload
```json
{
  "alert_id": "rta-1001",
  "conversation_id": "conv-1001",
  "waiting_message_id": "msg-9001",
  "assignment_id": "asn-2001",
  "cleared_at": "2026-04-24T09:21:03Z",
  "clear_reason": "human_reply"
}
```

## ManagementNotificationDispatched Payload Additions
```json
{
  "source_type": "response_timeout",
  "source_id": "rta-1001"
}
```

- `source_type` and `source_id` are optional additions for compatibility with existing consumers.
- Canonical values are:
  - `source_type = urgent_intervention`, `source_id = intervention_id`
  - `source_type = response_timeout`, `source_id = alert_id`
- Consumers must tolerate missing `source_type` and `source_id` on legacy dispatch records.

## Shared Type Names
- `TenantContext`
- `UserContext`
- `ConversationContext`
- `MessageEnvelope`
- `AttachmentRef`
- `MediaObject`
- `AssetItem`
- `LinkCardTemplate`
- `InterventionRule`
- `UrgentIntervention`
- `ResponseTimeoutPolicy`
- `ResponseTimeoutAlert`
- `NotificationEndpoint`
- `NotificationDelivery`
- `AiDecisionContext`
- `AiDecisionResult`
- `ToolExecutionRequest`
- `ToolExecutionResult`
- `AuditEnvelope`

## Contract Rules
- Public APIs may not infer tenant from nullable client input when a trusted resolver exists.
- Events must be idempotent and replay-safe.
- Removing or renaming event fields requires an ADR and migration notes.
- Realtime consumers must tolerate at-least-once delivery and replay by `message_id` plus `sequence`.
- Management notification delivery must be idempotent by `source_type + source_id + endpoint_id + template_version`.

# Multi-Tenant And Domain Model

## Tenant Model
- `tenant_id` is a first-class system key, not a loose string passed around ad hoc.
- Tenant context must come from trusted resolution:
  - authenticated operator token
  - verified channel binding
  - trusted internal event envelope
- Missing tenant context is a hard failure.
- There is no production default tenant.

## Identity And Roles
- Authentication model for V1: local account + tenant-scoped RBAC.
- Core roles:
  - `agent`
  - `supervisor`
  - `qa`
  - `tenant_admin`
  - `platform_admin`
- `platform_admin` actions are explicit and separately audited.

## Conversation Model
- Core aggregates:
  - `Conversation`
  - `Message`
  - `ConversationEvent`
  - `ConversationProjection`
- Conversation modes:
  - `Human`
  - `Copilot`
  - `Autopilot`
  - `Assist`
  - `HandoffPending`
- Message types:
  - `text`
  - `image`
  - `video`
  - `system`
  - `asset`
  - `link_card`

## Routing Model
- Core routing entities:
  - `ChannelGroup`
  - `Queue`
  - `QueueTicket`
  - `Assignment`
  - `Transfer`
  - `AgentPresence`
  - `InterventionRule`
  - `UrgentIntervention`
- Routing rules are configuration-driven per tenant.
- Assist replies do not change the primary assigned agent.
- Transfer must preserve the full conversation and audit chain.
- Inactivity auto-offline is owned by `routing-service`, not inferred by the frontend alone.

## Urgent Intervention Model
- High-risk keyword monitoring is tenant-configured and routing-owned.
- Matching is deterministic in V1 and runs on committed customer text messages.
- Intervention notifications are side-lane effects and may not block chat truth or realtime delivery.
- Device enrichment is optional and comes only from trusted business facts.
- Every intervention and delivery attempt must be auditable, idempotent, and tenant-scoped.

## Media Model
- User can send:
  - text
  - image
  - video
- AI can understand:
  - text
  - image
- AI cannot understand in V1:
  - video
- Video policy:
  - always persist metadata and preview path
  - always hand off to human
  - always record `video_not_supported_in_v1` as the reason

## Asset Library Model
- Fixed outbound assets are tenant-scoped.
- Asset types:
  - `image`
  - `video`
  - `link_card`
- Every asset must carry:
  - `tenant_id`
  - `asset_type`
  - `business_tags`
  - `channel_support`
  - `review_status`
  - `effective_from`
  - `effective_to`
  - `version`
- AI may only choose assets that are:
  - tenant-visible
  - channel-compatible
  - reviewed
  - currently effective

## Business Fact Boundaries
- Device, order, SIM, refund, and after-sales facts are authoritative only when returned by owned business APIs or controlled tools.
- AI-generated text is never a source of truth for device or order state.
- Search projections, analytics projections, and AI summaries are derived data only.

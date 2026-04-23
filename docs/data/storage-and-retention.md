# Storage And Retention

## Storage Responsibilities

| Store | Role | Owns Truth? | Notes |
| --- | --- | --- | --- |
| PostgreSQL | transactions, audit, AI config, knowledge metadata, embeddings | Yes | per-service schema or database ownership; acked inbound chat truth must already be committed here |
| OpenSearch | chat search read-side | No | rebuildable from source truth and events |
| Redis | presence, short-lived cache, backplane, idempotency windows | No | tenant-prefixed keys only |
| RabbitMQ | async workflow and event delivery | No | outbox/inbox required; durable quorum queues for critical domain events |
| MinIO/S3 | attachments, raw documents, fixed assets | No | object metadata still belongs to services |

## PostgreSQL Core Models
- `conversation-service`
  - `message_log`
  - `conversation_event`
  - `conversation_projection`
  - `evaluation`
  - `outbox_message`
- `routing-service`
  - `queue`
  - `queue_ticket`
  - `assignment`
  - `transfer`
  - `agent_presence`
- `media-service`
  - `media_object`
  - `media_review`
  - `asset_item`
  - `link_card_template`
- `ai-service`
  - `prompt_profile`
  - `reply_policy`
  - `tool_policy`
  - `asset_selection_policy`
  - `tenant_ai_settings`
  - `ai_audit`
- `knowledge-service`
  - `knowledge_document`
  - `knowledge_document_version`
  - `knowledge_chunk`
  - `knowledge_chunk_embedding`
  - `knowledge_release`
  - `knowledge_feedback`

## Partitioning Rules
- `message_log` is partitioned monthly by `occurred_at`.
- Large audit/event tables should use the same time-based partitioning pattern.
- Queries for chat replay and retention jobs must always include time ranges where possible.

## Retention Rules
- Chat search projection in OpenSearch:
  - online for 365 days
- Chat transactional truth in PostgreSQL:
  - retained according to business/legal policy, not automatically deleted with search projection
- Redis:
  - ephemeral only
- RabbitMQ:
  - durable until consumers succeed or dead-letter policy handles poison messages
- Object storage:
  - original assets follow service-level retention and legal hold policies

## Multi-Tenant Data Rules
- Every persisted business row includes `tenant_id` unless the record is truly global and explicitly guarded.
- Cache keys must start with `tenant_id`.
- Search documents must include `tenant_id`.
- Object keys must be tenant-scoped, for example:
  - `tenant-a/channel/2026/04/24/msg-001/image-original.jpg`

## OpenSearch Is Derived Data
- Never patch business truth only in OpenSearch.
- Never use OpenSearch as the authoritative source for replay, audit, billing, or device operations.
- Rebuildability is mandatory: if a search index is lost, it must be recreatable from PostgreSQL plus events.

## Recovery Rules
- Inbound message success must only be acknowledged after PostgreSQL source-of-truth commit succeeds.
- Outbox relay may retry safely after restart.
- Consumer projections must be replay-safe and idempotent.

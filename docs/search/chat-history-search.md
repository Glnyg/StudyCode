# Chat History Search

## Goal
Provide fast, tenant-safe chat history search for the agent and supervisor workbench without turning the transactional PostgreSQL cluster into the primary search engine.

## Why OpenSearch
- Search is a first-class read-side capability, not an ad hoc SQL query.
- The workbench needs:
  - keyword search
  - highlight
  - structured filters
  - paging
  - autocomplete
  - 1-year online retention
- These requirements justify a dedicated search read model while keeping PostgreSQL as source of truth.

## Scope For V1
- Searchable:
  - text messages
  - conversation and participant metadata
  - queue/channel/status filters
  - device/order identifiers when attached as structured fields
- Filterable only:
  - media presence
  - media type
- Not searchable in V1:
  - video content
  - image understanding summary
  - raw AI rationale

## Data Flow
1. `conversation-service` writes source-of-truth rows.
2. `conversation-service` writes outbox events.
3. RabbitMQ delivers events to `search-service`.
4. `search-service` updates OpenSearch documents idempotently.
5. Search APIs query OpenSearch and return hit metadata.
6. Full conversation replay comes back from `conversation-service`.

## Core Events
- `MessageAppended`
- `MessageRedacted`
- `ConversationTagged`
- `TransferCompleted`
- `AiHandoffChanged`
- `ConversationClosed`

## Search Document
- Document id: `tenant_id + ":" + message_id`
- Required fields:
  - `tenant_id`
  - `conversation_id`
  - `message_id`
  - `sender_type`
  - `customer_id`
  - `agent_id`
  - `channel`
  - `queue_id`
  - `conversation_status`
  - `message_type`
  - `search_text`
  - `has_media`
  - `device_id`
  - `order_id`
  - `occurred_at`
  - `tags`

## OpenSearch Mapping Rules
- `tenant_id`, `conversation_id`, `message_id`, `customer_id`, `agent_id`, `channel`, `queue_id`, `conversation_status`, `message_type`, `device_id`, `order_id`, `tags`:
  - `keyword`
- `search_text`:
  - primary text field using built-in `ngram` or equivalent internal analyzer for CJK partial matching
- `search_text.autocomplete`:
  - dedicated `edge_ngram` field for autocomplete
- `occurred_at`:
  - `date`
- No third-party Chinese plugin in V1.
- No mixed use of autocomplete field for full search ranking.

## Query Model
- Mandatory tenant filter on every request.
- Supported inputs:
  - `q`
  - `from_time`
  - `to_time`
  - `customer_id`
  - `agent_id`
  - `channel`
  - `queue_id`
  - `conversation_status`
  - `message_type`
  - `has_media`
  - `device_id`
  - `order_id`
  - `tags`
  - `page_size`
  - `search_after`
- Default sorting:
  - `occurred_at desc`
  - stable tie-breaker on `message_id`

## Search Result Model
- Per hit:
  - `conversation_id`
  - `message_id`
  - `occurred_at`
  - `sender_type`
  - `channel`
  - `queue_id`
  - `conversation_status`
  - `highlights`
  - `has_media`
  - `device_id`
  - `order_id`
- No silent fallback to full PostgreSQL scan.
- If OpenSearch is unavailable, return an explicit degraded-search error.

## Retention And Rebuild
- Online search retention:
  - 30 days hot
  - 31-365 days warm
- After 365 days:
  - delete search projection
  - keep or archive transactional truth according to PostgreSQL retention rules
- Rebuild strategy:
  - re-stream domain events or replay source-of-truth exports into `search-service`

## API Examples
```json
POST /search/messages
{
  "tenant_id": "tenant-a",
  "q": "套餐 续费",
  "channel": "wechat_customer_service",
  "queue_id": "after_sales",
  "from_time": "2026-04-01T00:00:00Z",
  "to_time": "2026-04-24T23:59:59Z",
  "page_size": 50
}
```

```json
{
  "items": [
    {
      "conversation_id": "conv-1001",
      "message_id": "msg-9001",
      "occurred_at": "2026-04-24T09:10:11Z",
      "sender_type": "customer",
      "channel": "wechat_customer_service",
      "queue_id": "after_sales",
      "conversation_status": "open",
      "highlights": [
        "请问这个<em>套餐</em>怎么<em>续费</em>？"
      ],
      "has_media": false,
      "device_id": "wifi-001",
      "order_id": "order-002"
    }
  ],
  "next_search_after": [
    "2026-04-24T09:10:11Z",
    "msg-9001"
  ]
}
```

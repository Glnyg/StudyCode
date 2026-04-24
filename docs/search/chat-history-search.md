# Chat History Search（聊天记录搜索）

## Goal（目标）
为 agent 和 supervisor workbench（客服与主管工作台）提供 fast（快速）、tenant-safe（租户安全）的聊天记录搜索能力，同时避免把 transactional PostgreSQL cluster（事务型 PostgreSQL 集群）变成主搜索引擎。

## Why OpenSearch（为什么使用 OpenSearch）
- Search 是 first-class read-side capability（一级读侧能力），不是临时拼出来的 SQL 查询。
- workbench 需要：
  - keyword search（关键词搜索）
  - highlight（高亮）
  - structured filters（结构化过滤）
  - paging（分页）
  - autocomplete（自动补全）
  - 1-year online retention（1 年在线保留）
- 这些需求足以证明应该有 dedicated search read model（专用搜索读模型），同时继续让 PostgreSQL 保持 source of truth。

## Scope For V1（V1 范围）
- 可搜索（searchable）的内容：
  - text messages（文本消息）
  - conversation 与 participant metadata（会话与参与者元数据）
  - queue / channel / status filters
  - 作为结构化字段附带的 device / order identifiers
- 只可过滤（filterable only）的内容：
  - media presence（是否有媒体）
  - media type（媒体类型）
- V1 不支持搜索（not searchable）的内容：
  - video content（视频内容）
  - image understanding summary（图片理解摘要）
  - raw AI rationale（原始 AI 推理理由）

## Data Flow（数据流）
1. `conversation-service` 写入 source-of-truth rows（事实源行记录）。
2. `conversation-service` 写入 outbox events。
3. RabbitMQ 把事件投递给 `search-service`。
4. `search-service` 以 idempotent（幂等）方式更新 OpenSearch documents。
5. Search APIs 查询 OpenSearch 并返回 hit metadata（命中元数据）。
6. 完整的 conversation replay（会话重放）仍然回到 `conversation-service`。

## Core Events（核心事件）
- `MessageAppended`
- `MessageRedacted`
- `ConversationTagged`
- `TransferCompleted`
- `AiHandoffChanged`
- `ConversationClosed`

## Search Document（搜索文档）
- document id 固定为：`tenant_id + ":" + message_id`
- 必备字段（required fields）：
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

## OpenSearch Mapping Rules（OpenSearch 映射规则）
- 以下字段必须使用 `keyword`：
  - `tenant_id`
  - `conversation_id`
  - `message_id`
  - `customer_id`
  - `agent_id`
  - `channel`
  - `queue_id`
  - `conversation_status`
  - `message_type`
  - `device_id`
  - `order_id`
  - `tags`
- `search_text`：
  - 主文本字段，使用 built-in `ngram` 或等价内置 analyzer（分析器）支持 CJK partial matching（中日韩部分匹配）
- `search_text.autocomplete`：
  - 专门的 `edge_ngram` 字段，用于 autocomplete
- `occurred_at`：
  - `date`
- V1 不引入第三方中文插件（Chinese plugin）。
- 不允许把 autocomplete field 混用为 full search ranking（全文搜索排序）字段。

## Query Model（查询模型）
- 每个请求都必须带 mandatory tenant filter（强制租户过滤），tenant 从 trusted context（可信上下文）解析，不依赖客户端自报。
- 支持的输入（supported inputs）包括：
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
- 默认排序（default sorting）：
  - `occurred_at desc`
  - 在 `message_id` 上使用 stable tie-breaker（稳定次级排序）

## Search Result Model（搜索结果模型）
- 每个 hit（命中）返回：
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
- 不允许 silent fallback（静默降级）到 PostgreSQL 全表文本扫描。
- 如果 OpenSearch 不可用，必须返回 explicit degraded-search error（显式降级搜索错误）。

## Retention And Rebuild（保留与重建）
- online search retention（在线搜索保留）：
  - 30 天 hot（热数据）
  - 31-365 天 warm（温数据）
- 365 天之后：
  - 删除 search projection（搜索投影）
  - transactional truth（事务真相）根据 PostgreSQL retention rules 保留或归档
- rebuild strategy（重建策略）：
  - 把 domain events 重新流式投递，或把 source-of-truth exports（事实源导出）回放进 `search-service`

## API Examples（接口示例）
请求中的 tenant 由认证上下文解析，下面的 body 不再重复传 `tenant_id`。

```json
POST /search/messages
{
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

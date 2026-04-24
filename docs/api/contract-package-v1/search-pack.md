# Search Pack（搜索合同包）

## Scope（范围）
- 冻结 chat-history search 的 query、result、autocomplete、health 合同。
- 冻结 `search_after` 分页约定和 degraded-search error（降级搜索错误）。
- 冻结 `search-service` 对 conversation 事件的最小依赖集合。

## APIs（接口）
- `OpenAPI`: [openapi/search-service.openapi.yaml](./openapi/search-service.openapi.yaml)

### HTTP Surface（HTTP 接口面）
- `POST /v1/search/messages`
- `GET /v1/search/autocomplete`
- `GET /v1/search/health`

## Event Dependencies（事件依赖）
- `JSON Schema`: [schemas/conversation-events.schema.json](./schemas/conversation-events.schema.json)
- required inputs（必需输入）：
  - `MessageAppended`
  - `MessageRedacted`
  - `ConversationTagged`
  - `ConversationClosed`
  - `TransferCompleted`
  - `AiHandoffChanged`

## Contract Rules（合同规则）
- 每个请求都必须带 mandatory tenant filter（强制租户过滤）。
- search 只接受 `search_after`，不支持 offset / page number。
- OpenSearch 不可用时必须返回统一错误 envelope，并且 `code = search.degraded_unavailable`。
- search hit（搜索命中）永远只返回 projection fields（投影字段）；完整消息回放必须回到 `conversation-service`。

## Negative Cases（负例）
- missing tenant context（缺少租户上下文）：
  - `401 tenant.context_missing` / `403 tenant.forbidden_cross_tenant`
- malformed `search_after`（格式错误的 `search_after`）：
  - `400 search.invalid_search_after`
- OpenSearch unavailable（OpenSearch 不可用）：
  - `503 search.degraded_unavailable`
- cross-tenant conversation replay link attempt（跨租户跳转会话重放链接）：
  - `404 conversation.not_found`

## Compatibility Notes（兼容性说明）
- `next_search_after` 的数组顺序固定为 `[occurred_at, message_id]`。
- `highlights` 是 projection 字段，可以新增展示 metadata（展示元数据），但不能变成 source-of-truth text（事实源文本）。

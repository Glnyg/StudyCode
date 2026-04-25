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
- tenant filter 只能来自 bearer token 解析出的 trusted `TenantContext`，不能来自客户端 body / query 声明。
- search 只接受 `search_after`，不支持 offset / page number。
- autocomplete / health 之类 `GET` search surface 不接受 request body；复杂结构化检索继续使用 `POST /v1/search/messages`。
- search operator error（搜索操作员错误）必须直接返回真实 HTTP status，不允许 outer `200 + inner error`。
- OpenSearch 不可用时必须返回统一错误 envelope，并且 `code = search.degraded_unavailable`。
- search hit（搜索命中）永远只返回 projection fields（投影字段）；完整消息回放必须回到 `conversation-service`。

## Negative Cases（负例）
- missing / invalid token（缺少 / 无效令牌）：
  - `401 gateway.identity_invalid`
- valid token but missing `search.read`（令牌有效但缺少搜索权限）：
  - `403 search.permission_denied`
- `GET /v1/search/autocomplete` 或 `GET /v1/search/health` 携带 request body：
  - `400 gateway.request_invalid`
- malformed `search_after`（格式错误的 `search_after`）：
  - `400 search.invalid_search_after`
- OpenSearch unavailable（OpenSearch 不可用）：
  - `503 search.degraded_unavailable`
- cross-tenant conversation replay link attempt（跨租户跳转会话重放链接）：
  - `404 conversation.not_found`

## Compatibility Notes（兼容性说明）
- `next_search_after` 的数组顺序固定为 `[occurred_at, message_id]`。
- `highlights` 是 projection 字段，可以新增展示 metadata（展示元数据），但不能变成 source-of-truth text（事实源文本）。

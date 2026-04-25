# Public Contracts And Events（公共接口与事件）

## Purpose（用途）
- 这篇文档现在是公共接口（public APIs）和事件（events）的入口索引，不再承载所有细节合同。
- 具体合同已经冻结到 [contract-package-v1/README.md](./contract-package-v1/README.md)。

## Authoritative Contract Package（权威合同包）
- 主入口：
  - [contract-package-v1/README.md](./contract-package-v1/README.md)
- 相关 tenant / authorization freeze：
  - [../domain/tenant-resolution-and-authorization-v1.md](../domain/tenant-resolution-and-authorization-v1.md)
- 横切规则（cross-cutting rules）：
  - [contract-package-v1/shared-contract-core.md](./contract-package-v1/shared-contract-core.md)
- 缺口审计（gap audit）与优先级：
  - [contract-package-v1/00-gap-audit-and-workstreams.md](./contract-package-v1/00-gap-audit-and-workstreams.md)
- 合同测试基线（contract-test baseline）：
  - [contract-package-v1/contract-test-baseline.md](./contract-package-v1/contract-test-baseline.md)

## HTTP Contract Artifacts（HTTP 合同产物）
- `conversation-service`
  - [openapi/conversation-service.openapi.yaml](./contract-package-v1/openapi/conversation-service.openapi.yaml)
- `routing-service`
  - [openapi/routing-service.openapi.yaml](./contract-package-v1/openapi/routing-service.openapi.yaml)
- `search-service`
  - [openapi/search-service.openapi.yaml](./contract-package-v1/openapi/search-service.openapi.yaml)
- `media-service`
  - [openapi/media-service.openapi.yaml](./contract-package-v1/openapi/media-service.openapi.yaml)
- `ai-service`
  - [openapi/ai-service.openapi.yaml](./contract-package-v1/openapi/ai-service.openapi.yaml)
- edge boundary（边缘边界）
  - [openapi/edge-boundaries.openapi.yaml](./contract-package-v1/openapi/edge-boundaries.openapi.yaml)

## Event And Shared Schema Artifacts（事件与共享 Schema 产物）
- shared types（共享类型）
  - [schemas/shared-types.schema.json](./contract-package-v1/schemas/shared-types.schema.json)
- error envelope（统一错误信封）
  - [schemas/error-envelope.schema.json](./contract-package-v1/schemas/error-envelope.schema.json)
- event envelope（统一事件信封）
  - [schemas/event-envelope.schema.json](./contract-package-v1/schemas/event-envelope.schema.json)
- conversation events（会话事件）
  - [schemas/conversation-events.schema.json](./contract-package-v1/schemas/conversation-events.schema.json)
- routing and alerting events（路由与告警事件）
  - [schemas/routing-alerting-events.schema.json](./contract-package-v1/schemas/routing-alerting-events.schema.json)
- asset and AI events（资产与 AI 事件）
  - [schemas/asset-ai-events.schema.json](./contract-package-v1/schemas/asset-ai-events.schema.json)

## Event Catalog V1（事件目录）
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

## Shared Rules（共享规则）
- trusted `tenant_id` 只能来自 token、verified channel binding（已验证通道绑定）或 trusted internal event envelope（可信内部事件信封）。
- operator bearer token 采用单租户 session model（会话模型），claims 固定为 `sub`, `tenant_id`, `actor_type`, `role`, `permissions`, `session_id`。
- `platform_admin` 不能直接复用 tenant-scoped operator APIs；必须走显式 admin surface。
- error envelope 的 `code` 与 `error_source` 必须能区分 gateway problem（网关问题）和 system problem（系统问题）：
  - `gateway.*` 只用于 edge / gateway failure
  - service / domain / dependency / internal failure 统一标记 `error_source = system`
- operator/public API 出错时必须直接返回真实 HTTP status，不能用 outer `200` 包装 auth、tenant、permission、validation、gateway 或 system failure。
- `GET` request 不接受 body；如果客户端发送 body，必须返回 `400` request-shape violation（请求形状违规）。
- side-effecting `POST`（有副作用的 POST）必须显式声明是否要求 `Idempotency-Key`。
- versioned config writes（版本化配置写入）使用 `If-Match`。
- search 分页使用 `search_after`。
- realtime replay（实时重放）使用 `last_seen_sequence`。
- events 必须 replay-safe（可重放）并兼容 at-least-once delivery（至少一次投递）。
- breaking contract change（破坏性合同变更）必须同步更新 ADR、examples、negative cases、compatibility notes。

## Change Workflow（变更流程）
1. 先更新 `contract-package-v1/` 下的权威合同。
2. 如果变更涉及 trusted tenant resolution、token claims、`TenantContext`、permission strings、operator/public response strategy 或 `platform_admin` 边界，同步更新 `docs/domain/tenant-resolution-and-authorization-v1.md`。
3. 如果涉及 breaking change，同步更新 `docs/adr/0010-freeze-contract-package-v1-as-implementation-ready-baseline.md` 或新增 ADR。
4. 再同步 `Obsidian/05-API/公共接口与事件目录.md`。
5. 最后才允许实现代码跟进。

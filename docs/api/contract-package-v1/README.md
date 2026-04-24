# Contract Package V1（合同冻结包 V1）

## Goal（目标）
- 把目前还停留在说明性 prose（文字描述）的接口与事件设计，升级成可冻结、可评审、可并行实现的合同包。
- 这套包为后续实现统一提供 `OpenAPI 3.1`、事件 `JSON Schema`、shared conventions（共享约定）、examples（示例）、negative cases（负例）和 compatibility rules（兼容性规则）。

## Scope（范围）
- 包含：
  - `conversation-service`
  - `routing-service`
  - `search-service`
  - `media-service`
  - `ai-service`
  - 最小必要的 `api-gateway` / `realtime-gateway` 边界
- 不包含：
  - 完整 `tenant/auth freeze package`
  - 详细 PostgreSQL 表结构
  - 上游 webhook / 业务系统集成的全量冻结
  - 没有明确设计依据的新 `gRPC` 接口

## Package Layout（包结构）
- [00-gap-audit-and-workstreams.md](./00-gap-audit-and-workstreams.md)
  - 现状缺口、owner / consumer 矩阵、依赖顺序、并行包划分
- [shared-contract-core.md](./shared-contract-core.md)
  - trusted tenant context、actor / request context、trace、幂等、乐观并发、错误 envelope、分页、replay、event versioning
- [conversation-and-realtime-pack.md](./conversation-and-realtime-pack.md)
  - 会话查询、消息回放、agent send、会话评价、SignalR replay 边界
- [routing-and-alerting-pack.md](./routing-and-alerting-pack.md)
  - queue / assignment / transfer / presence、urgent intervention、response-timeout
- [search-pack.md](./search-pack.md)
  - search / autocomplete / health、`search_after`、projection 依赖事件、degraded-search 错误
- [media-pack.md](./media-pack.md)
  - 资产上传、审核、列表、预览 URL、asset reference
- [ai-pack.md](./ai-pack.md)
  - suggestion、execute、policy snapshot、audit、tool gating、fallback / asset selection
- [contract-test-baseline.md](./contract-test-baseline.md)
  - 合同测试、兼容性检查、负例场景、收口验收
- `openapi/`
  - 各服务的 `OpenAPI 3.1` 合同
- `schemas/`
  - shared types（共享类型）、error envelope、event envelope 与事件目录 `JSON Schema`

## Contract Outputs（合同产物）
- HTTP 合同默认使用 `OpenAPI 3.1`。
- 事件合同使用 `JSON Schema Draft 2020-12`，每个 schema 文件都应带 example。
- 当前包不新增 `.proto`：
  - 正式设计虽然已经允许“在有依据时使用 `gRPC`”，但还没有冻结到“哪个 owner 暴露哪条 RPC、谁消费、怎样处理幂等和恢复”的粒度。
  - 因此这一轮只冻结 `realtime-gateway` 的最小边界与 replay semantics（重放语义），不凭空发明内部 RPC。

## Service Artifact Map（服务产物映射）

| 合同包 | 主要 owner | 主要 consumers | 机器可读产物 |
| --- | --- | --- | --- |
| Shared Contract Core | cross-cutting governance（横切治理） | all services | `schemas/shared-types.schema.json`, `schemas/error-envelope.schema.json`, `schemas/event-envelope.schema.json` |
| Conversation + Realtime | `conversation-service`, `realtime-gateway` | `routing-service`, `search-service`, `ai-service`, operator console | `openapi/conversation-service.openapi.yaml`, `schemas/conversation-events.schema.json` |
| Routing + Alerting | `routing-service` | operator console, `realtime-gateway`, analytics consumers | `openapi/routing-service.openapi.yaml`, `schemas/routing-alerting-events.schema.json` |
| Search | `search-service` | operator console, supervisors | `openapi/search-service.openapi.yaml` |
| Media | `media-service` | operator console, `ai-service` | `openapi/media-service.openapi.yaml`, `schemas/asset-ai-events.schema.json` |
| AI | `ai-service` | operator console, `conversation-service`, `routing-service` | `openapi/ai-service.openapi.yaml`, `schemas/asset-ai-events.schema.json` |
| Edge Boundary | `api-gateway`, `realtime-gateway` | operator console | `openapi/edge-boundaries.openapi.yaml` |

## Priority（优先级）
- `P0 / Lane 0`
  - 先完成 gap audit（缺口审计）、shared contract core（共享合同核心）和 shared schema（共享 schema）
- `P0 / Lane 1`
  - `conversation-service + realtime edge`
  - `routing-service`
- `P1 / Lane 1`
  - `search-service`
  - `media-service`
  - `ai-service`
- `P1 / Lane 2`
  - examples、negative cases、compatibility notes、ADR、Obsidian 同步、contract-test baseline

## Completion Criteria（完成标准）
- 所有已在正式设计文档中出现的 public APIs、关键事件、shared types，都必须在这套包里有明确 owner、consumer、schema 和 example。
- 多租户、幂等、恢复、兼容性规则不再依赖聊天记忆；后续实现者不需要自行决定 header、error、version、`Idempotency-Key`、`sequence` 或 event envelope 的形状。
- `docs/api/public-contracts-and-events.md` 只保留入口索引职责，不再承担全部合同细节。
- 只要对外行为或事件兼容性规则发生变化，就先改这里，再改实现。

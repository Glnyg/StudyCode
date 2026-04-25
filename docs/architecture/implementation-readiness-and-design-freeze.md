# Implementation Readiness And Design Freeze（实现就绪与设计冻结）

## Goal（目标）
说明哪些架构决策已经冻结（frozen）、哪些内容在真正编码前仍然缺失，以及把 blueprint（蓝图）转成可执行项目工作时的推荐顺序。

## Current Status（当前状态）
系统在 blueprint level（蓝图层）已经完整。

除非通过 ADR 显式变更，以下决策都视为已冻结：
- runtime baseline：`.NET 10 LTS`
- deployment baseline：`RKE2 Kubernetes`，单生产集群（single production cluster），多节点高可用（multi-node HA）
- service topology：`2` 个 edge services + `10` 个 business services
- truth vs read-side split（真相与读侧拆分）：
  - `PostgreSQL + pgvector` 是 source of truth
  - `OpenSearch` 仅用于 chat-history search read-side
  - `Redis` 只用于 ephemeral state（临时状态）
  - `RabbitMQ` 只用于 async delivery（异步投递）
  - `MinIO/S3` 只用于 object storage
- realtime hot path rules 和 side-lane rules
- AI service boundaries、policy model、multimodal V1 范围、tool-execution constraints
- 单 service 和单 worker-node 故障下的 recovery semantics
- 官方实现风格：
  - core transactional domains 使用 `Pragmatic DDD`
  - orchestration、adapter、projection-heavy services 使用 `Workflow-first`
  - `Selective CQRS`
  - `Layered TDD`

## What Is Not Missing Anymore（已经不再缺失的决策）
在真正编码前，不需要再对以下一阶架构问题重新争论：
- `.NET 10` 还是 `.NET 8`
- PostgreSQL 是否能继续作为 AI truth store
- chat search 是否需要 `OpenSearch`
- 是否每个 service 都必须 full DDD / CQRS
- V1 是否应该支持 AI hot path 中的视频理解
- `Contract Package V1` 是否已经足够作为 HTTP / event contract baseline
- `Tenant Resolution And Authorization V1` 是否还要继续靠聊天记忆临场发明
- operator/public API 出错时到底该返回真实 HTTP status，还是 outer `200` + inner code
- `GET` surface 是否允许 request body

这些决策已经足够支撑 implementation planning（实现规划）。

## What Is Still Missing Before Real Coding（真正编码前仍缺的内容）
剩余缺口属于 implementation-freeze items（实现冻结项），不是 architecture-direction items（架构方向争论）。

如果你想直接按执行视角检查 blocker（阻塞项）和 freeze package（冻结包），请同时查看：
- [implementation-freeze-checklist.md](./implementation-freeze-checklist.md)

当前已冻结完成、无需再阻塞后续 slice 的项：
- `Contract Package V1`
- `Tenant Resolution And Authorization V1`
- operator/public HTTP response strategy（真实 HTTP status + `code` + `error_source`，且 `GET` 不接受 request body）

### P0: PostgreSQL Detailed Schema V1
在 domain implementation 与 migrations 之前必须冻结。

必需产物：
- 每个 source-of-truth service 的逐表 logical schema
- primary keys、unique keys、foreign-key strategy（如适用）
- time partition rules
- hot queries 所需 indexes
- idempotency keys
- conversation replay 的 sequence rules
- audit columns
- outbox / inbox schema details
- retention 与 archive hooks

完成标准：
- 写 migrations 时不需要现场发明核心业务字段
- replay、dedupe、audit 行为已经编码进 schema 规则，而不是靠聊天记忆

### P0: Upstream Integration Specs V1
在 `channel-service` 与 `device-service` 之前必须冻结。

必需产物：
- Enterprise WeChat customer-service webhook contract
- official-account callback contract
- upstream retry 与 dedupe behavior
- media callback 与 media-fetch flow
- outbound send contract 与 provider idempotency strategy
- device / order / after-sales upstream API mapping
- partial failure 后的 reconciliation 与 compensation rules

完成标准：
- adapter code 可以对着明确的 upstream semantics（上游语义）实现
- retry 与 duplicate-delivery 行为是设计结果，而不是临场 improvisation（临场发挥）

### P0: Engineering Baseline V1
在大范围 scaffolding 之前必须冻结。

必需产物：
- repository layout 与 solution structure
- shared building blocks 的边界
- package / version management strategy
- local development topology
- configuration layering by environment
- CI pipeline stages
- Helm chart 与 values conventions
- environment matrix：
  - local
  - dev
  - staging
  - production

完成标准：
- 新 services 都遵守同一种仓库形态
- local bring-up 与 CI checks 可复现
- deployment manifests 不会无规则地按 service 分裂

## P1 Items That May Follow Initial Scaffolding（初始脚手架后可继续冻结的 P1 项）
这些内容不阻塞第一个 shared skeleton，但在对应里程碑启动前必须冻结。

### Search Freeze Package
- final OpenSearch mappings
- index template 与 lifecycle policy
- projection replay contract
- rebuild job API 与 operational runbook

### AI Freeze Package
- policy / config schema fields
- publish / rollback workflow
- prompt assembly rules
- tool manifest format
- audit payload schema
- evaluation metric definitions

### Media And Asset Freeze Package
- media-processing job contract
- virus scan 与 moderation states
- asset review workflow
- URL signing 与 preview rules

### Observability And SRE Freeze Package
- service SLOs
- latency / error / saturation alerts
- dashboards 与 trace requirements
- failure-drill scripts 与 ownership

### Intervention And Notification Freeze Package
- intervention rule schema 与 severity model
- cooldown 与 dedupe rules
- management notification endpoint model 与 secret-reference rules
- payload templates 与 redaction rules
- acknowledgement 与 resolution workflow
- device-enrichment timeout 与 fallback rules
- provider retry 与 dead-letter runbook

## Recommended Delivery Order（推荐交付顺序）
1. 冻结 `PostgreSQL Detailed Schema V1`。
2. 冻结 `Engineering Baseline V1`。
3. 实现 `conversation-service` 的 source-of-truth core 加 outbox。
4. 实现 `routing-service` 与 `realtime-gateway`。
5. 在实现 `channel-service` 之前冻结 `Upstream Integration Specs V1`。
6. 实现 `channel-service` 的 inbound / outbound adapters。
7. 实现 `search-service` 的 projection 与 query path。
8. 实现 `media-service` 与 asset governance。
9. 实现 `knowledge-service` 与 `ai-service`。
10. 实现 `analytics-service`。
11. 强化平台交付、故障演练与生产运维。

## Definition Of Ready For Coding（编码就绪定义）
只有以下条件全部满足，才允许开始 coding：
- blueprint docs 和 ADR baseline 已批准
- 当前 slice（切片）对应的 contract package V1 已冻结
- 当前 slice 对应的数据模型 V1 已冻结
- 当前 slice 对应的 tenant / auth rules 已冻结
- 当前 slice 需要的 tests 已提前明确
- implementation order 不依赖未解决的架构争论

## Definition Of Ready For The First Milestone（首个里程碑就绪定义）
第一个里程碑是 realtime conversation loop（实时会话闭环）。

在以下内容冻结前，不允许开始：
- inbound message contract
- agent send contract
- message、conversation、outbox、replay schema
- console 与 channel webhook 的 tenant resolution rules
- `conversation-service` 与 `routing-service` 之间的 queue assignment interaction
- 带 `message_id` 和 `sequence` 的 websocket replay contract
- duplicate-delivery 与 retry semantics

## Governance Rule（治理规则）
如果未来讨论重新打开了本文件已经冻结的话题，默认答案是：
- 不重新设计架构
- 把具体缺口追加到对应的 freeze package
- 只有当 runtime、data ownership 或 safety boundaries 真正变化时，才新增 ADR

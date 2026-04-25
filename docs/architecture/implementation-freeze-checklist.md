# Implementation Freeze Checklist（实现冻结清单）

## Goal（目标）
把 [implementation-readiness-and-design-freeze.md](./implementation-readiness-and-design-freeze.md) 里的“仍需冻结项”改写成可直接执行的 checklist（清单），方便在 scaffolding（脚手架）、建模、集成和里程碑排期前做 readiness review（就绪评审）。

配套的可跟踪 issue 文档位于：
- [issues/README.md](./issues/README.md)

## How To Use（怎么使用）
1. 先确认当前要启动的 slice（切片）属于哪个里程碑。
2. 对照本清单确认：哪些事项已经在权威文档中冻结，哪些还没有。
3. 只有当前 slice 对应的 blocker（阻塞项）都已冻结，才允许进入代码实现。
4. 如果新增未覆盖的实现前决策，把它追加到对应 freeze package（冻结包），而不是重新打开已冻结的大架构讨论。

## Already Frozen（已冻结完成）
- [x] `Contract Package V1` 已作为 HTTP / event contract baseline（合同基线）。
- [x] `Tenant Resolution And Authorization V1` 已作为 tenant / auth baseline（租户与授权基线）。
- [x] operator/public HTTP response strategy 已冻结为真实 HTTP status + error envelope，不使用 outer `200 + inner error`。
- [x] `GET` surface 不接受 request body。

## P0 Blockers Before Broad Coding（大范围编码前的 P0 阻塞项）

### 1. PostgreSQL Detailed Schema V1
对应 issue：
- [issues/p0-01-postgresql-detailed-schema-v1.md](./issues/p0-01-postgresql-detailed-schema-v1.md)

适用范围：
- `conversation-service`
- `routing-service`
- `identity-service`
- `knowledge-service`
- 其他持有 source-of-truth tables（事实源表）的服务

Checklist：
- [ ] 为每个 source-of-truth service 冻结逐表 logical schema（逻辑表结构）。
- [ ] 冻结 primary keys、tenant-scoped unique keys、foreign-key strategy（如适用）。
- [ ] 冻结 time partition rules（时间分区规则）和 hot-query indexes（热点查询索引）。
- [ ] 冻结 idempotency keys、dedupe namespace（去重命名域）和 payload mismatch 处理规则。
- [ ] 冻结 `message_id`、`sequence`、replay cursor 和 committed ordering（提交顺序）规则。
- [ ] 冻结 audit columns、redaction markers（脱敏/删改标记）和 actor metadata。
- [ ] 冻结 outbox / inbox schema、consumer checkpoint（消费者检查点）和 replay-safe 约束。
- [ ] 冻结 retention、archive hooks（归档钩子）和 rebuild 所需导出字段。

完成标准：
- migrations（迁移）编写时不需要现场发明核心字段。
- replay、dedupe、audit 行为已经编码进 schema 规则。

主要参考：
- [implementation-readiness-and-design-freeze.md](./implementation-readiness-and-design-freeze.md)
- [storage-and-retention.md](../data/storage-and-retention.md)
- [power-loss-and-recovery.md](../reliability/power-loss-and-recovery.md)

### 2. Engineering Baseline V1
对应 issue：
- [issues/p0-02-engineering-baseline-v1.md](./issues/p0-02-engineering-baseline-v1.md)

适用范围：
- 仓库结构
- shared building blocks（共享构件）
- 本地开发与 CI/CD
- Helm / environment conventions（环境约定）

Checklist：
- [ ] 冻结 repository layout（仓库目录）和 solution structure（解决方案结构）。
- [ ] 冻结 shared building blocks 的边界，明确哪些能力能进 shared、哪些必须留在 service 内。
- [ ] 冻结 package / version management strategy（包与版本管理策略）。
- [ ] 冻结 local development topology（本地开发拓扑），包括依赖组件的最小 bring-up 方式。
- [ ] 冻结 configuration layering by environment（按环境分层的配置策略）。
- [ ] 冻结 CI pipeline stages（流水线阶段）和最小必跑 checks（必跑检查）。
- [ ] 冻结 Helm chart layout、values conventions 和环境覆盖策略。
- [ ] 冻结 environment matrix（`local` / `dev` / `staging` / `production`）及其差异说明。

完成标准：
- 新 service 遵守同一种仓库形态。
- local bring-up、CI checks 和 deployment manifests 可复现。

主要参考：
- [implementation-readiness-and-design-freeze.md](./implementation-readiness-and-design-freeze.md)
- [k8s-baseline.md](../platform/k8s-baseline.md)
- [verification-baseline.md](../testing/verification-baseline.md)

### 3. Upstream Integration Specs V1
对应 issue：
- [issues/p0-03-upstream-integration-specs-v1.md](./issues/p0-03-upstream-integration-specs-v1.md)

适用范围：
- `channel-service`
- `device-service`
- management notification providers（管理通知提供方）

Checklist：
- [ ] 冻结 Enterprise WeChat customer-service webhook contract（含 payload mapping、验签后字段语义、错误处理）。
- [ ] 冻结 official-account callback contract（公众号回调合同）和 tenant-safe normalization（租户安全归一化）规则。
- [ ] 冻结 upstream retry / duplicate-delivery semantics（重试与重复投递语义）。
- [ ] 冻结 media callback、media fetch、asset ingest flow（素材接入流）。
- [ ] 冻结 outbound send contract、provider acknowledgement model（上游确认模型）和 provider idempotency strategy。
- [ ] 冻结 device / order / after-sales upstream API mapping（上游接口映射）与 anti-corruption boundary（防腐边界）。
- [ ] 冻结 partial failure 下的 reconciliation（对账修复）、compensation（补偿）和 operator-visible error semantics。

完成标准：
- adapter code 可以直接对着上游语义实现。
- retry、dedupe、补偿与恢复行为是设计结果，不是临场决定。

主要参考：
- [implementation-readiness-and-design-freeze.md](./implementation-readiness-and-design-freeze.md)
- [tenant-resolution-and-authorization-v1.md](../domain/tenant-resolution-and-authorization-v1.md)
- [power-loss-and-recovery.md](../reliability/power-loss-and-recovery.md)

## First Milestone Readiness Snapshot（首个里程碑就绪快照）
首个里程碑是 realtime conversation loop（实时会话闭环）。

当前已由冻结包覆盖的项：
- [x] inbound message contract
- [x] agent send contract
- [x] console 与 channel webhook 的 tenant resolution rules
- [x] 带 `message_id` 和 `sequence` 的 websocket replay contract
- [x] duplicate-delivery / idempotency 的合同级语义

当前仍需补齐的项：
- [ ] `message`、`conversation`、`outbox`、replay schema 的数据模型冻结

说明：
- `conversation-service` 与 `routing-service` 的 assignment / event interaction（分配与事件交互）已在 `Contract Package V1` 中有 owner、API 和 event baseline；真正还缺的是落库级 schema 冻结，而不是再次重开接口方向争论。

## P1 Freeze Packages By Milestone（按里程碑推进的 P1 冻结包）

### Search Freeze Package
- 对应 issue：
  - [issues/p1-01-search-freeze-package.md](./issues/p1-01-search-freeze-package.md)
- [ ] final OpenSearch mappings
- [ ] index template 与 lifecycle policy
- [ ] projection replay contract
- [ ] rebuild job API
- [ ] operational runbook

主要参考：
- [chat-history-search.md](../search/chat-history-search.md)

### AI Freeze Package
- 对应 issue：
  - [issues/p1-02-ai-freeze-package.md](./issues/p1-02-ai-freeze-package.md)
- [ ] policy / config schema fields
- [ ] publish / rollback workflow
- [ ] prompt assembly rules
- [ ] tool manifest format
- [ ] audit payload schema
- [ ] evaluation metric definitions

主要参考：
- [ai-service-design.md](../ai/ai-service-design.md)
- [knowledge-rag-design.md](../ai/knowledge-rag-design.md)

### Media And Asset Freeze Package
- 对应 issue：
  - [issues/p1-03-media-and-asset-freeze-package.md](./issues/p1-03-media-and-asset-freeze-package.md)
- [ ] media-processing job contract
- [ ] virus scan 与 moderation states
- [ ] asset review workflow
- [ ] URL signing 与 preview rules

主要参考：
- [media-pack.md](../api/contract-package-v1/media-pack.md)

### Observability And SRE Freeze Package
- 对应 issue：
  - [issues/p1-04-observability-and-sre-freeze-package.md](./issues/p1-04-observability-and-sre-freeze-package.md)
- [ ] service SLOs
- [ ] latency / error / saturation alerts
- [ ] dashboards 与 trace requirements
- [ ] failure-drill scripts
- [ ] ownership model

主要参考：
- [k8s-baseline.md](../platform/k8s-baseline.md)
- [verification-baseline.md](../testing/verification-baseline.md)

### Intervention And Notification Freeze Package
- 对应 issue：
  - [issues/p1-05-intervention-and-notification-freeze-package.md](./issues/p1-05-intervention-and-notification-freeze-package.md)
- [ ] intervention rule schema 与 severity model
- [ ] cooldown 与 dedupe rules
- [ ] management notification endpoint model 与 secret-reference rules
- [ ] payload templates 与 redaction rules
- [ ] acknowledgement 与 resolution workflow
- [ ] device-enrichment timeout 与 fallback rules
- [ ] provider retry 与 dead-letter runbook

主要参考：
- [urgent-intervention-and-management-alerting.md](../domain/urgent-intervention-and-management-alerting.md)
- [response-timeout-alerting.md](../domain/response-timeout-alerting.md)

## Recommended Working Order（推荐推进顺序）
1. 先关闭 `PostgreSQL Detailed Schema V1`。
2. 再关闭 `Engineering Baseline V1`。
3. 然后启动 `conversation-service` / `routing-service` / `realtime-gateway` 的实现。
4. 在实现 `channel-service` 与 `device-service` 前，关闭 `Upstream Integration Specs V1`。
5. 之后按 `search -> media -> knowledge + ai -> analytics` 推进各自的 P1 freeze package。

## Governance Reminder（治理提醒）
- 这份清单解决的是 implementation readiness（实现就绪），不是重新选择大架构。
- 如果缺的是字段、恢复语义、上游协议、工程规约，就补 freeze package。
- 只有 runtime baseline、data ownership、tenant boundary、AI safety boundary 真变化时，才需要新增或修改 ADR。

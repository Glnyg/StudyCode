# Customer Service Authority Package（客服系统权威设计包）

## Purpose（用途）
- `docs/` 是这个便携 WiFi 客服系统的正式设计权威目录（formal source of truth）。
- 代码生成（code generation）、实现（implementation）、评审（review）和后续 AI-assisted changes（AI 辅助改动），都应先遵守这里的文档，再参考聊天上下文。

## Precedence（权威顺序）
1. `docs/`
2. `Obsidian/`
3. 聊天记忆（chat memory）

`AGENTS.md` 提供硬性的流程和安全护栏（guardrails），但不替代正式设计文档。

## Reading Style（阅读方式）
- 本仓库的正式说明文档默认用中文表达。
- 大多数常用英文术语会保留英文，并尽量写成 `English（中文）`，帮助读者逐步熟悉英文工作表达。
- services、events、shared types、headers、paths、schema keys 等正式 contract identity（合同标识）保持英文，不会在文档里被重命名。

## Entry Points（入口文档）
- `architecture/system-overview.md`：系统目标、运行模型（operating model）和顶层架构。
- `architecture/service-boundaries-and-runtime-topology.md`：service ownership（服务归属）、runtime lanes（运行时通道）和 hot-path rules（热路径规则）。
- `architecture/implementation-readiness-and-design-freeze.md`：哪些内容已经 freeze（冻结）、哪些内容仍然阻塞 coding（编码）、推荐交付顺序是什么。
- `architecture/implementation-freeze-checklist.md`：把实现前仍需冻结的事项整理成可执行 checklist（清单），用于 readiness review（就绪评审）。
- `architecture/issues/README.md`：把待冻结事项拆成可单独跟踪的 issue 文档，方便直接复制到 GitHub issue 或内部任务系统。
- `architecture/implementation-style-pragmatic-ddd-workflow-first.md`：官方实现风格，说明 DDD/CQRS 在哪里适用，哪里应该 workflow-first。
- `domain/multi-tenant-and-domain-model.md`：tenant model、identity、conversation lifecycle、routing、media、asset boundaries。
- `domain/tenant-resolution-and-authorization-v1.md`：trusted tenant resolution、single-tenant operator token、RBAC matrix、`platform_admin` 边界，以及 operator/public HTTP 的真实状态码与错误 / 审计语义。
- `domain/urgent-intervention-and-management-alerting.md`：高风险关键词告警（urgent intervention）、管理通知（management notification）和设备补充信息（device enrichment）规则。
- `search/chat-history-search.md`：chat history search（聊天记录搜索）设计和 OpenSearch read-side 规则。
- `ai/ai-service-design.md`：AI service 结构、policy model、tool execution、multimodal handling。
- `ai/knowledge-rag-design.md`：knowledge base 与 RAG 的数据流、发布和评估。
- `data/storage-and-retention.md`：PostgreSQL、OpenSearch、Redis、RabbitMQ、object storage 的职责划分。
- `reliability/power-loss-and-recovery.md`：掉电恢复（power loss and recovery）、不丢消息保证（no-loss guarantees）、replay rules 和单节点故障行为。
- `api/public-contracts-and-events.md`：API / event contract 入口索引、变更流程，以及 gateway/system 错误区分规则。
- `api/contract-package-v1/README.md`：面向实现的 `OpenAPI` / `JSON Schema` 合同冻结包（contract package）。
- `platform/k8s-baseline.md`：Kubernetes 基线、observability（可观测性）和交付规则。
- `testing/verification-baseline.md`：验收检查、故障演练（failure drills）和性能目标。
- `testing/test-strategy-and-quality-gates.md`：测试层级（test layers）、质量闸门（quality gates）和“tests have guarantees”的含义。
- `adr/`：已经冻结的架构决策（architectural decisions）。

## Design Change Workflow（设计变更流程）
1. 在第一次代码改动之前或同时，先更新相关设计文档。
2. 如果变更涉及 runtime、data ownership、search architecture、AI policy model 或 tenant boundaries，就新增或修订 ADR。
3. 把最终设计同步到对应的 `Obsidian/` note。
4. 然后才允许 scaffold 或修改实现代码。

## Current Baseline（当前基线）
- Runtime：`.NET 10 LTS`
- Deployment：`RKE2 Kubernetes`，单生产集群（single production cluster），多节点高可用（multi-node HA）
- Transaction source of truth：`PostgreSQL + pgvector`
- Search read-side：`OpenSearch`
- Messaging：`RabbitMQ`
- Realtime：`SignalR`
- Object storage：`MinIO/S3`

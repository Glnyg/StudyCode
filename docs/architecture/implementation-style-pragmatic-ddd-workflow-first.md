# Implementation Style: Pragmatic DDD / Workflow-First（实现风格）

## Goal（目标）
定义这个系统的官方实现风格（official implementation style），让后续代码既保持一致，也保持 production-safe（生产可用），同时避免把单一模式强行套在每个 service 上。

## Official Recommendation（官方建议）
使用：
- `Pragmatic DDD` 处理 source-of-truth（事实源）核心服务中的强不变量
- `Workflow-first` application services（应用服务）处理 adapter、orchestration、projection-heavy services
- `Selective CQRS` 处理读写模型差异显著的场景
- `Layered TDD` 让 tests 优先保护最危险的层

这是仓库推荐风格，优先于“全项目统一 Full DDD/CQRS”。

## Why This Style Fits This System（为什么适合本系统）
- 这个系统同时包含：
  - hard transactional domains（强事务域）
  - realtime delivery（实时投递）
  - search projections（搜索投影）
  - AI policy orchestration（AI 策略编排）
  - upstream adapters（上游适配器）
- 它们的 failure modes（失败模式）和 modeling needs（建模需求）不同。
- 如果强行 everywhere 都用同一种风格，结果只会是：
  - 核心域建模不足（under-model）
  - adapter / projection 过度 ceremony（形式主义）

## Default Internal Structure（默认内部结构）
- 推荐的 service 内部形态：
  - transport layer（传输层）
  - application layer（应用层）
  - domain layer（在有必要时）
  - infrastructure / adapters（基础设施与适配器）
- 更推荐按 vertical slices（垂直切片）组织高内聚功能，而不是一味按技术层切目录。
- domain model 要与 HTTP、MQ、OpenSearch、model SDK、storage-specific details 隔离。

## Where Pragmatic DDD Applies（适合 Pragmatic DDD 的地方）

### `conversation-service`
使用 `DDD + rich domain model`。

原因：
- 强状态转换
- message sequencing rules（消息序号规则）
- conversation mode changes（会话模式变化）
- audit-sensitive invariants（审计敏感不变量）
- replay 与 idempotency constraints（重放与幂等约束）

推荐 aggregates（聚合）：
- `Conversation`
- `Message`
- `ConversationTimeline`
- `ConversationEvaluation`

### `routing-service`
使用 `DDD + rich domain model`。

原因：
- queue lifecycle（队列生命周期）
- assignment rules（分配规则）
- transfer invariants（转接不变量）
- inactivity offline rules（不活跃自动离线规则）
- agent state transitions（客服状态迁移）

推荐 aggregates：
- `QueueTicket`
- `Assignment`
- `Transfer`
- `AgentPresence`

### `knowledge-service`
使用 moderate `DDD`（适度 DDD）。

原因：
- review / publish / rollback invariants
- release visibility rules（版本可见性规则）
- lifecycle governance（生命周期治理）

推荐 aggregates：
- `KnowledgeDocument`
- `KnowledgeRelease`
- `LearningCandidate`

### `media-service` 的 asset governance（资产治理）
使用 selective `DDD`（选择性 DDD）。

原因：
- review state（审核状态）
- effective dates（生效时间）
- channel compatibility（渠道兼容性）
- tenant visibility（租户可见性）

推荐 aggregates：
- `AssetItem`
- `LinkCardTemplate`

## Where Workflow-First Wins（适合 Workflow-first 的地方）

### `channel-service`
推荐风格：
- adapter layer
- request normalization（请求归一化）
- signature validation（签名校验）
- idempotent webhook handling（幂等回调处理）
- explicit application services / transaction scripts

原因：
- 它主要是 integration-heavy（集成密集型）防腐层

### `search-service`
推荐风格：
- projection builders
- OpenSearch mappers
- query services
- rebuild jobs

原因：
- 它持有的是 derived read models，不是 business-truth aggregates

### `analytics-service`
推荐风格：
- aggregators
- read-model builders
- reporting query services

原因：
- analytics 本质是 projection-oriented（投影导向）的派生能力

### `ai-service`
推荐风格：
- orchestrator
- policy objects
- workflow steps
- explicit tool executor
- audit logger

原因：
- 它的复杂性来自 decision flow（决策流）、risk control（风险控制）、fallback（回退）、external calls（外部调用）
- 不是来自单个强聚合根

### `device-service`
推荐风格：
- anti-corruption layer（防腐层）
- application services
- upstream adapter mapping

原因：
- 它包装的是上游真相，不是内部深度业务真相

## Selective CQRS Guidance（选择性 CQRS 指南）
- 只有在 read / write models 差异显著时，CQRS 才是强制性的。
- 这个系统已经在架构层需要 CQRS 的地方包括：
  - `conversation-service` 写侧 vs `search-service` 读侧
  - transactional truth vs analytics read models
- 在 service 内部，只有以下条件满足时才引入 CQRS：
  - command 与 query models 确实不同
  - 扩缩容需求不同
  - validation 与 side effects 明显不同
- 不要为了 trivial CRUD（简单增删改查）拆 handler-per-endpoint 或重复的 command/query types。

## Layered TDD Guidance（分层 TDD 指南）

### Core Domain Services（核心领域服务）
先写：
- aggregate invariant tests（聚合不变量测试）
- legal / illegal state transition tests（合法 / 非法状态迁移测试）
- duplicate / replay safety tests（重复投递 / 重放安全测试）

再写：
- application service tests
- repository / integration tests

### Workflow And Integration Services（工作流与集成服务）
先写：
- workflow tests
- adapter tests
- contract tests
- idempotency tests

### Search And Analytics（搜索与分析）
优先写：
- projection tests
- mapping tests
- query behavior tests
- rebuild / replay tests

### AI
优先写：
- policy decision tests
- tool gating tests
- fallback tests
- prompt / config resolution tests
- audit completeness tests

避免把 brittle model-output snapshots（脆弱模型输出快照）当成主要信心来源。

## Test Assurance Rules（测试保证规则）
- 不能因为“有测试通过”就宣称改动已被充分测试。
- 变化所在层必须有对应的正确测试类型：
  - domain rule change -> domain invariant tests
  - workflow / orchestration change -> application / integration tests
  - contract change -> contract tests
  - projection / search change -> projection / query / rebuild tests
  - AI policy change -> policy / fallback / audit tests
- 每个 source-of-truth rule change 都必须至少有一个“没有这次改动就会失败”的测试。
- 每条 replay-sensitive path 都必须覆盖 duplicate delivery 或 retry。

## Repository-Level Review Questions（仓库级评审问题）
- 这个 service 持有的是 source-of-truth 还是 derived data？
- 它是在保护真实不变量，还是主要在编排外部系统？
- rich aggregate（充血聚合）能否减少重复规则，还是只会增加 ceremony？
- CQRS 是否真的解决了读写模型差异？
- tests 是否保护了最高风险层？

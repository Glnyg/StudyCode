# ADR 0007：采用选择性 DDD/CQRS 与分层 TDD

## Status（状态）
Accepted（已接受）

## Context（背景）
系统横跨 core transactional domains、integration adapters、derived read models 和 AI orchestration。如果所有地方强制一种实现风格，要么导致核心服务 domain logic 贫血，要么让 adapter / projection 服务充满过度 ceremony。

## Decision（决策）
- 在强不变量的核心领域里，使用 DDD 和 rich domain models。
- 只有当读写模型差异显著时，才使用 CQRS。
- 在 adapter、projection、orchestration-heavy services 里，使用 workflow / application-service 风格。
- 全项目使用 TDD，但测试层级要根据 service 类型和风险来选。

## Consequences（影响）
- 不同 services 的实现风格会有意不同。
- Reviewers 应同时拒绝 over-modeling（过度建模）和 under-modeling（建模不足）。
- 因为选择标准写清楚了，所以整体架构仍然保持一致。

# 实现风格：Pragmatic DDD 与 Workflow-first

对应正式文档：`docs/architecture/implementation-style-pragmatic-ddd-workflow-first.md`

## 这是什么
- 这是这个项目官方推荐的代码实现风格。
- 它不是“所有服务统一一种模式”，而是按服务职责选最合适的实现方式。

## 先给结论
- [[Pragmatic DDD]]：用于核心业务域。
- [[Workflow-first]]：用于接入、编排、搜索投影、AI 编排这类流程型模块。
- [[CQRS]]：只在读写差异明显的地方使用。
- [[TDD]]：全项目适用，但测试层次必须对。

## 为什么它比全量 DDD 更适合
- 这个系统里既有“强业务规则核心域”，也有“接入、搜索、AI 编排、报表”这类流程型模块。
- 如果全量硬上 [[DDD]] 和 [[充血模型]]，很容易把简单服务做得过重。
- 如果全部都用事务脚本，又会让核心域规则散落各处。

## 哪些服务适合 Pragmatic DDD
- [[conversation-service]]
- [[routing-service]]
- [[knowledge-service]]
- [[media-service]] 的素材治理

## 哪些服务适合 Workflow-first
- [[channel-service]]
- [[search-service]]
- [[analytics-service]]
- [[ai-service]]
- [[device-service]]

## 测试怎么保证
- 核心域：先写领域不变量测试
- 编排服务：先写应用服务和契约测试
- 搜索：写投影、查询、重建测试
- AI：写策略、回退、审计测试

## 你要记住
- 不是“有没有测试”，而是“有没有对的测试”。
- 一个低价值 smoke test，不等于测试有保障。

## 工作里怎么用
- 讨论代码结构时，不再问“要不要全量 DDD”，而是问：
  - 这是核心域还是流程型模块？
  - 这里最容易出错的层是哪一层？
  - 最应该先被测试保护的是哪一层？

## 面试怎么说
- “我更倾向 Pragmatic DDD 与 Workflow-first。核心域用 DDD 和充血模型守住不变量，接入和编排型服务保持显式流程，搜索和分析走读模型，整体通过分层 TDD 保证质量。”

## 继续学习
- [[Pragmatic DDD]]
- [[Workflow-first]]
- [[DDD]]
- [[CQRS]]
- [[TDD]]
- [[充血模型]]

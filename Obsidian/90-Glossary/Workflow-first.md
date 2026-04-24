# Workflow-first

## 是什么
- 指优先把代码组织成清晰的业务流程、编排步骤和应用服务，而不是先堆复杂领域对象。

## 在本项目里怎么用
- [[channel-service]]、[[search-service]]、[[ai-service]]、[[analytics-service]] 更适合 Workflow-first。

## 生产里要注意
- Workflow-first 不等于随便写。
- 仍然需要清晰边界、契约、重试、幂等和错误处理。

## 面试怎么说
- “Workflow-first 适合集成和编排型服务，因为它把流程和失败处理写得更清楚，也避免过度建模。”

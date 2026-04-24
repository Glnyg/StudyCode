# 05-API 阅读导航

## 这部分讲什么
- 这里讲系统对外接口、对内事件、共享字段约束，以及契约变更时要同步更新哪些面。

## 为什么重要
- 对这个项目来说，接口和事件不是“实现细节”，而是跨服务协作的正式边界。
- 如果契约漂移，最先出问题的通常不是单个服务，而是整个调用链和下游消费者。

## 建议先读
1. [[公共接口与事件目录]]

## 对应正式文档
- `docs/api/public-contracts-and-events.md`

## 读完去哪里
- 想看服务职责：[[01-Architecture/README|01-Architecture]]
- 想看测试要求：[[09-Testing/README|09-Testing]]
- 想看租户边界：[[02-Domain/README|02-Domain]]

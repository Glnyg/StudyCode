# ADR 0010：冻结 [[Contract Package V1]] 作为实现前置合同基线

对应正式文档：`docs/adr/0010-freeze-contract-package-v1-as-implementation-ready-baseline.md`

## 背景
- 这个项目的架构蓝图已经比较完整，但真正能让多人或多个 AI 并行实现的“接口合同包”还没冻结。
- 如果没有统一的 `HTTP`、事件、错误码、幂等和重放规则，不同实现者会各自发明自己的契约。
- 这类问题通常不是单点 bug，而是长期的[[微服务]]协作漂移。

## 决策
- 把 [[Contract Package V1]] 定成实现前必须遵守的正式合同基线。
- `HTTP` 接口统一先写成 [[OpenAPI]]。
- 事件和共享 payload 统一先写成 [[JSON Schema]]。
- 统一冻结 trusted `tenant` 上下文、`Idempotency-Key`、`If-Match`、错误 envelope、`search_after`、`last_seen_sequence` 和事件 envelope 规则。
- 没有明确设计冻结之前，不为了“看起来完整”而硬加 [[gRPC]] `.proto`。
- 人类可读说明默认中文优先，但正式 contract identity（合同标识）继续保持英文。

## 影响
- 后面的实现者不需要再争论 header、错误码、幂等键和 replay 语义。
- [[conversation-service]]、[[routing-service]]、[[search-service]]、[[media-service]]、[[ai-service]] 可以在统一规则下并行推进。
- 以后如果真的要改公共契约，必须先改正式合同和 ADR，而不是直接改代码。

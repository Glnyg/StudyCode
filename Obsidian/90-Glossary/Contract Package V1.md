# Contract Package V1

## 这是什么
- `Contract Package V1` 是把系统的正式接口契约打包在一起的一组文档和 schema。
- 它不只是“接口说明”，而是实现前必须先冻结的正式基线。

## 为什么重要
- 如果没有统一契约，不同服务、不同开发者、不同 AI 很容易各自发明字段、错误码和幂等规则。
- 这会让系统出现“代码能跑，但边界不一致”的隐形故障。

## 在本项目里怎么用
- 本项目把 `docs/api/contract-package-v1/` 作为公共接口和事件契约的正式落点。
- 里面同时冻结：
  - `HTTP API`
  - 事件 schema
  - 共享类型
  - 错误 envelope
  - 幂等、并发、分页、replay 和兼容性规则
- 这套文档的人类可读说明默认用中文，但正式标识例如 service name、event name、schema key、path 继续保持英文。

## 工作里怎么用
- 你要改接口，先改 `Contract Package V1`。
- 你要改事件，也先改这里。
- 如果是 breaking change，还要同步改 ADR 和迁移说明。

## 面试怎么说
- “我会把 API 和事件契约做成正式的 contract package，而不是散落在聊天和口头约定里。这样团队和多 agent 协作时更稳。”

## 你下一步应该看什么
1. [[OpenAPI]]
2. [[JSON Schema]]
3. [[05-API/公共接口与事件目录|公共接口与事件目录]]

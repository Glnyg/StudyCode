# Upstream Integration Specs V1

## 它是什么
- 这是外部集成的实现冻结包。
- 它把 [[Webhook]]、上游回调、发消息接口、媒体拉取、设备/订单/售后系统映射，以及失败后的补偿语义统一写清楚。

## 为什么重要
- 外部系统最危险的地方，不是“能不能接上”，而是“重复一次、失败一次、半成功一次之后会不会乱”。
- 如果没有这份冻结包，`channel-service` 和 `device-service` 很容易把重试、幂等、补偿和租户边界写散。

## 本项目怎么用
- 它应该冻结：
  - 企业微信客服回调
  - 公众号回调
  - 上游 retry / dedupe 语义
  - media callback / fetch flow（媒体回调与拉取流程）
  - outbound send contract（出站发送合同）
  - provider idempotency（上游幂等）
  - device / order / after-sales API mapping（设备 / 订单 / 售后映射）
  - reconciliation / compensation（对账修复 / 补偿）规则

## 工作里怎么落地
- 你应该先冻结 provider semantics（供应商语义），再写 adapter（适配器）。
- 这样 duplicate delivery（重复投递）、partial failure（部分失败）和 operator-visible errors（操作员可见错误）才会一致。

## 面试里怎么表达
- “我不会把外部集成当成简单 SDK 接入。我会先冻结 webhook、重试、幂等、补偿和对账语义，再实现 anti-corruption layer。” 

## 你下一步应该看什么
1. [[Webhook]]
2. [[幂等]]
3. [[Tenant Resolution]]
4. [[开工前设计冻结清单]]

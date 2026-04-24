# ADR 0009：客服未回复超时告警保持为路由侧旁路能力

对应正式文档：`docs/adr/0009-response-timeout-alerting-stays-as-routing-owned-side-lane.md`

## 背景
- 系统需要支持“客户已经进入人工接待，但超过配置时间还没有收到人工回复”的内部提醒。
- 这类提醒要发到企微、飞书等管理渠道，必要时还要补设备信息。
- 这个能力不能拖慢客服实时聊天主流程。

## 决策
- 把这项能力归到 [[routing-service]]。
- 基于已提交的 [[MessageAppended]]、接待变更和关单事实异步维护等待窗口。
- 单独定义 [[ResponseTimeoutPolicy]] 和 [[ResponseTimeoutAlert]]，不复用 [[UrgentIntervention]]。
- 通知发送继续复用 [[routing-service]] 里的管理通知适配层。
- 第一版不单独拆 `notification-service`。

## 影响
- 聊天热路径不变。
- “投诉升级”和“客服未回复超时”可以共享通知能力，但不会共享业务语义。
- 后续要扩展重复提醒、升级路径或统计指标时，不需要回头拆旧模型。

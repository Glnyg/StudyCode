# ResponseTimeoutAlertTriggered

## 是什么
- 表示一次 [[ResponseTimeoutAlert]] 已经正式触发。

## 何时触发
- 当 [[routing-service]] 复验等待窗口仍然超时后创建告警记录并触发该事件。
- 它说明“这轮客户等待已经超过租户配置的人工回复时限”。

## 关键字段
- 载荷重点包括 `alert_id`、`conversation_id`、等待消息、接待关系、坐席、策略、开始等待时间、到期时间和触发时间。
- 可选设备补充状态也会随事件一起带出。

## 消费时要注意
- 一轮等待只应产生一次有效告警事件。
- 下游要按 `alert_id` 或 dedupe 语义保证幂等。
- 告警通知和设备补充都不能反过来阻塞主链路。

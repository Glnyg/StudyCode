# UrgentInterventionTriggered

## 是什么
- 表示一次 [[UrgentIntervention]] 已经被触发。

## 何时触发
- 当 [[routing-service]] 基于 [[InterventionRule]] 命中结果创建或复用紧急介入记录后触发。
- 它是高风险告警旁路正式开始的信号。

## 关键字段
- 载荷重点包括 `intervention_id`、`conversation_id`、触发消息、规则、严重级别、命中词、队列和设备补充状态。
- 这些字段让下游知道“哪次高风险介入发生了，以及为什么发生”。

## 消费时要注意
- 通知、分析和主管视图要按 `intervention_id` 做幂等消费。
- 它不能阻塞聊天持久化或实时推送。
- 设备补充失败也不能否定介入事件已经成立。

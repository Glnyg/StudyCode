# routing-service

## 是什么
- 负责队列、分配、转接、坐席在线状态，以及告警旁路的路由服务。

## 在本项目里怎么用
- 它管理 [[QueueTicket]]、[[Assignment]]、[[Transfer]] 这些路由对象。
- 它消费 [[MessageAppended]] 等已提交事件，驱动 [[InterventionRule]]、[[UrgentIntervention]]、[[ResponseTimeoutPolicy]] 和 [[ResponseTimeoutAlert]] 的生命周期。
- 它还负责把内部管理通知交给相应的 [[NotificationEndpoint]] 去发送，并记录 [[NotificationDelivery]]。

## 生产里要注意
- 它不拥有消息持久化真相，消息真相仍然归 [[conversation-service]]。
- 告警、转接、分配和通知发送都必须严格带 [[多租户]] 边界。
- 重放或重复投递时不能重复建单、重复提醒或串租户。

## 面试怎么说
- “routing-service 负责把会话放到正确的人和队列上，同时承接告警和介入这种控制域旁路，但不越权拥有消息真相。”

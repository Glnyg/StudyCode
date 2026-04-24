# NotificationEndpoint

## 是什么
- 表示内部管理通知要发送到哪里的端点配置。

## 关键字段或状态
- 关键字段包括提供商类型、渠道名、密钥引用、模板标识、启用状态和版本。
- 它定义“这类告警最终要发到哪个群、机器人或渠道”。

## 在本项目里怎么用
- [[UrgentIntervention]] 和 [[ResponseTimeoutAlert]] 都会复用 [[NotificationEndpoint]] 作为通知目标。
- [[routing-service]] 根据租户配置选择端点，并把发送结果写入 [[NotificationDelivery]]。
- 端点配置通常对应企微、飞书等内部管理通知渠道。

## 生产里要注意
- 密钥和凭据应该通过 `secret_ref` 这类引用管理，不能直接写明文。
- 端点启停和模板版本要可追踪、可审计。
- 不同租户的通知端点绝不能混用。

# ADR 0009：客服未回复超时告警保持为路由侧拥有的旁路能力

## Status（状态）
Accepted（已接受）

## Context（背景）
系统需要支持 tenant-configured 的超时告警：当一个已经分配给人工的会话，在设定分钟数内没有人工回复时，向 Enterprise WeChat 或 Feishu 等管理渠道发内部提醒。它也可能需要补充 device enrichment，但不能阻塞 inbound chat durability 或 realtime agent delivery。

可选放置位置包括：
- `conversation-service`
- `routing-service`
- 新的 `notification-service`
- 外部 cron 或 observability tooling

## Decision（决策）
- 把 response-timeout alerting 保持为 `routing-service` owned capability。
- 在 source-of-truth commit 完成后，基于 `MessageAppended`、`ConversationAssigned`、`TransferCompleted`、`ConversationClosed` 异步触发。
- `ResponseTimeoutPolicy` 和 `ResponseTimeoutAlert` 与 `UrgentIntervention` 分开建模。
- timeout policy 按 tenant default + exact queue override 解析。
- 允许通过 `device-service` 做 optional device enrichment。
- 管理通知通过 `routing-service` 自己的 provider adapters 或 workers 发送。
- 除非 provider 范围或吞吐量未来真的需要，否则不新增独立 `notification-service`。

## Consequences（影响）
- hot chat path 保持不变。
- response-timeout policy、waiting-window state、management notification orchestration 保持在同一个 control-domain service。
- timeout alerts 与 keyword interventions 可以共用 notification adapters，但不共享 lifecycle semantics（生命周期语义）。
- notification failures 不会破坏 conversation truth。
- 未来如果要扩展 repeated reminders（重复提醒）或 escalations（升级机制），也不需要移动 message truth 或 routing ownership。

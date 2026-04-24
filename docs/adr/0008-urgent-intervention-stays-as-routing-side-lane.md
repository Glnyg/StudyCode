# ADR 0008：紧急介入保持为路由侧旁路能力

## Status（状态）
Accepted（已接受）

## Context（背景）
系统需要支持 tenant-configured 的高风险关键词检测，例如投诉、监管相关词汇，并把紧急介入通知发到 Enterprise WeChat 或 Feishu 等管理渠道。这个能力不能阻塞 inbound chat durability 或 realtime agent delivery。

可选放置位置包括：
- `ai-service`
- `analytics-service`
- 新的 `notification-service`
- `routing-service`

## Decision（决策）
- 把 urgent intervention 保持为 `routing-service` owned capability。
- 在 source-of-truth commit 完成后，由 `MessageAppended` 异步触发。
- V1 以 deterministic（确定性）的关键词 / 短语规则作为主触发方式。
- 允许通过 `device-service` 做 optional device enrichment。
- 管理通知通过 `routing-service` 自己持有的 provider adapters 或 workers 发送。
- 除非 provider 范围或吞吐量未来真的需要，否则不新增独立 `notification-service`。

## Consequences（影响）
- hot chat path 保持不变。
- urgent intervention、queue priority、supervisor visibility、acknowledgement 都留在同一个 control-domain service。
- notification failures 不会破坏 conversation truth。
- 未来如果要扩展到 AI-assisted classification，也不需要移动 message truth 或 routing ownership。

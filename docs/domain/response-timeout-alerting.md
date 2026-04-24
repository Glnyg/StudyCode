# Response Timeout Alerting（响应时限告警）

## Goal（目标）
提供一种 deterministic（确定性）、tenant-safe（租户安全）的方式，用来识别“已分配人工客服但客户等待超过配置分钟数仍未收到人工回复”的会话，并在不阻塞主聊天路径的前提下，向内部管理通知渠道发送告警。

## Scope For V1（V1 范围）
- 只对具有 active human assignment（活跃人工分配）的会话识别 customer-wait window（客户等待窗口）
- 支持按租户配置 timeout minutes（超时分钟数），并允许 exact queue override（精确队列覆盖）
- 创建可审计的 `response-timeout` 告警记录
- 按需用 trusted business facts（可信业务事实）补充设备信息
- 向 Enterprise WeChat、Feishu 等管理通知渠道发送内部提醒
- 当 human-visible agent reply（人工可见客服回复）、transfer（转接）或 conversation close（会话关闭）改变状态时，清除 waiting window

## Explicit Non-Goals For V1（V1 明确非目标）
- 不做“客服尚未分配前”的 queue-wait alerting（排队等待告警）
- 首次超时通知之后，不做 repeated reminder cadence（重复提醒节奏）或 escalation ladder（升级阶梯）
- 不复用 `UrgentIntervention` 的 acknowledgement / resolution workflow（确认/解决流程）
- day one 不要求拆独立 `notification-service`

## Design Principles（设计原则）
- response timeout alerting（响应时限告警）是 routing-owned side lane（路由持有的旁路流程），不是 realtime chat hot path 的一部分
- 先保证 customer message durability（客户消息持久化）和 agent push（客服推送），再在 source-of-truth commit 之后评估超时
- timer（定时器）必须 deterministic，并且只能基于 committed messages（已提交消息）和 trusted assignment facts（可信分配事实）
- device enrichment 是可选的，并且必须有超时边界
- notifications 可以 best-effort with retry，但 alert creation（告警创建）和 clear audit（清除审计）必须 durable

## Ownership（归属）
- `conversation-service` 持有 source-of-truth messages，并发布 `MessageAppended`
- `routing-service` 持有：
  - policy resolution（策略解析）
  - waiting-window state（等待窗口状态）
  - timeout alert lifecycle（超时告警生命周期）
  - dedupe and replay safety（去重与重放安全）
  - management notification dispatch orchestration（管理通知分发编排）
- `device-service` 提供可选 device / order enrichment
- `analytics-service` 可以投影 timeout KPI，但不能触发告警
- `channel-service` 不持有内部管理通知

## Policy Resolution（策略解析）
- V1 的策略查找顺序（policy lookup order）是：
  1. 当前 tenant 的 enabled exact queue match（已启用精确队列匹配）
  2. 当前 tenant 中未设置 `queue_scope` 的 enabled default policy（默认策略）
- 如果多个 enabled policies 可能同时命中同一个 tenant + queue，V1 必须拒绝该配置
- 如果没有 policy 命中，就不创建 timeout window（超时窗口）

## Timer Semantics（定时器语义）
- V1 只适用于具有 active human assignment 的会话
- 当客户消息提交后，`routing-service` 使用以下规则创建或刷新 waiting window：
  - `waiting_started_at = max(customer_message_committed_at, assignment_effective_at)`
  - `due_at = waiting_started_at + timeout_minutes`
- 第一条 human-visible agent outbound message（人工可见客服外发消息）会清除当前 waiting window
- AI draft generation、AI suggestions、internal notes（内部备注）和 hidden workflow messages（隐藏工作流消息）都不能清除等待窗口
- `ConversationAssigned` 或 `TransferCompleted` 会清除旧等待窗口，并按新的 assignment effective time（分配生效时间）为新客服重新计时
- `ConversationClosed` 会清除所有 pending waiting window；已经触发的 alerts 仍然保留审计记录，并带显式 `clear_reason`

## Runtime Flow（运行时流程）
1. `conversation-service` 提交客户消息和 outbox event。
2. `routing-service` 异步消费 `MessageAppended`。
3. `routing-service` 为当前 active assignment（活跃分配）和 queue 解析 tenant-scoped timeout policy（租户作用域超时策略）。
4. 如果命中策略，`routing-service` 以事务方式创建或更新 pending waiting window 和 due time（到期时间）。
5. timeout worker（超时 worker）扫描到期窗口，并重新校验会话是否仍然在等待同一 assignment。
6. 如果仍然到期，`routing-service` 创建 `ResponseTimeoutAlert` 记录并发布 `ResponseTimeoutAlertTriggered`。
7. 如果配置要求补充信息，`routing-service` 向 `device-service` 请求有界的 device snapshot。
8. notification worker 发送 Enterprise WeChat 或 Feishu 告警，并记录 delivery attempts。
9. 后续人工回复、转接或会话关闭会清除等待状态，并在需要时发布 `ResponseTimeoutAlertCleared`。

## Core Entities（核心实体）

### `ResponseTimeoutPolicy`
- `tenant_id`
- `policy_id`
- `enabled`
- `queue_scope`
- `timeout_minutes`
- `notify_policy_id`
- `device_enrichment_policy`
- `version`

### `ResponseTimeoutAlert`
- `tenant_id`
- `alert_id`
- `conversation_id`
- `waiting_message_id`
- `assignment_id`
- `agent_id`
- `queue_id`
- `policy_id`
- `status`
- `waiting_started_at`
- `due_at`
- `triggered_at`
- `cleared_at`
- `clear_reason`
- `enrichment_status`
- `dedupe_key`

这个 workflow 复用 urgent intervention 通知分发中的 `NotificationEndpoint` 和 `NotificationDelivery`。timeout alert 通知固定写入 `source_type = response_timeout` 和 `source_id = alert_id`。

## Notification Payload Rules（通知载荷规则）
- payload 可以包含：
  - tenant display name（租户显示名）
  - conversation id 或 console deep link
  - assigned agent display name（已分配客服显示名）和内部 id
  - queue
  - waiting duration（等待时长）
  - device snapshot（如果可用）
  - trigger time
- payload 不得包含：
  - secrets 或 tokens
  - raw provider credentials
  - 不必要的 customer PII
  - 默认情况下的完整会话转录

## Device Enrichment Rules（设备补充信息规则）
- enrichment 只能使用已经附着在 conversation 或 message context 上的 trusted identifiers
- `routing-service` 只能在 timeout alert 创建之后调用 `device-service`
- enrichment timeout 不能无限阻塞通知
- 如果 enrichment 失败或超时：
  - 通知仍然发送
  - delivery audit 记录 `enrichment_status`
  - 同步 dispatch path 里不允许隐藏重试循环

## Idempotency And Recovery Rules（幂等与恢复规则）
- 重复投递的 `MessageAppended`、`ConversationAssigned` 或 `TransferCompleted` 不能创建重复 waiting window 或 alert
- alert dedupe key（告警去重键）固定为 `tenant_id + waiting_message_id + assignment_id`
- 每一轮 waiting round（等待轮次）最多只允许发出一次外部提醒
- management notification dispatch 必须按 `source_type + source_id + endpoint_id + template_version` 幂等
- consumer 或 worker 重启后，所有 waiting windows、alerts 和 deliveries 都必须 replay-safe

## Operational Behavior（运行行为）
- notification provider failure 不能回滚 timeout alert record
- 失败通知必须异步重试，并显式推进 status transition
- 永久失败必须在 console 和 audit 中保持可见
- 这个 workflow 在部分故障期间可以 lag，但不能拖慢 chat persistence 或 realtime push

## Future Extensions（未来扩展）
- repeated reminder cadence（重复提醒节奏）或 escalation ladder
- assignment 之前的 queue-wait alerting
- supervisor auto actions（主管自动动作），例如队列升级
- 只有 provider 数量、template 复杂度或 notification throughput 真正支撑时，才拆独立 `notification-service`

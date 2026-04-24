# Urgent Intervention And Management Alerting（紧急介入与管理通知）

## Goal（目标）
提供一种 deterministic（确定性）、tenant-safe（租户安全）的方式，用来识别租户配置的高风险会话内容，例如投诉关键词，并在不阻塞主聊天路径（main chat path）的前提下触发管理层紧急介入。

## Scope For V1（V1 范围）
- 在客户入站文本消息（inbound customer text messages）中检测租户配置的关键词或短语
- 创建可审计（auditable）的 `urgent-intervention` 记录
- 按需用 trusted business facts（可信业务事实）补充 device information（设备信息）
- 向 Enterprise WeChat、Feishu 等管理通知渠道发送内部告警
- 允许管理者在控制台里确认（acknowledgement）并跟进

## Explicit Non-Goals For V1（V1 明确非目标）
- 不使用 AI semantic classifier（语义分类器）作为主触发机制
- 不做 image OCR、video ASR 或 video understanding（视频理解）来参与匹配
- 不在这个告警流里直接给客户自动回复
- 不把 assigned-agent response-timeout（已分配客服超时）或 customer-wait SLA（客户等待时限）告警混进这个模型
- day one（第一天）不要求拆独立的 `notification-service`

## Design Principles（设计原则）
- urgent intervention（紧急介入）是 side-lane workflow（旁路工作流），不是 realtime chat hot path（实时聊天热路径）的一部分
- 先完成消息持久化（message durability）和客服推送，再在 source-of-truth commit（事实源提交）之后做告警反应
- deterministic rules（确定性规则）优先于 AI heuristics（AI 启发式）
- device enrichment（设备补充信息）是可选的，并且必须有超时边界
- urgent intervention 和 response-timeout alerting 可以复用 notification adapters（通知适配器），但规则、记录和 lifecycle semantics（生命周期语义）必须分开
- notifications（通知）可以 best-effort with retry（尽力重试），但 alert creation（告警创建）和 audit（审计）必须是 durable（持久）的

## Ownership（归属）
- `conversation-service` 持有 source-of-truth messages（事实源消息），并发布 `MessageAppended`
- `routing-service` 持有：
  - intervention rule evaluation（介入规则评估）
  - intervention state（介入状态）
  - cooldown and dedupe（冷却与去重）
  - acknowledgement workflow（确认流程）
  - management notification dispatch orchestration（管理通知分发编排）
- `device-service` 提供可选的 device / order enrichment（设备或订单补充信息）
- `analytics-service` 可以投影 intervention KPI，但不能触发告警
- `channel-service` 不持有内部管理通知

## Runtime Flow（运行时流程）
1. `conversation-service` 提交入站消息和 outbox event（发件箱事件）。
2. `routing-service` 异步消费 `MessageAppended`。
3. intervention evaluator（介入评估器）检查当前消息对应的 tenant-scoped rules（租户作用域规则）。
4. 如果规则命中，`routing-service` 以事务方式创建或复用 `UrgentIntervention` 记录。
5. 如果配置要求补充信息，`routing-service` 向 `device-service` 发起有界（bounded）的 device snapshot（设备快照）请求。
6. `routing-service` 发布 `UrgentInterventionTriggered`。
7. notification worker（通知 worker）发送 Enterprise WeChat 或 Feishu 告警，并记录 delivery attempts（投递尝试）。
8. 管理者在控制台确认或解决该 intervention。

## Matching Rules（匹配规则）
- V1 只评估客户发送的 normalized text messages（归一化文本消息）。
- V1 支持的 rule operators（规则操作符）包括：
  - `contains_any`
  - `contains_all`
- V1 默认不支持任意 `regex`。
- 规则可以按以下维度设定 scope（作用域）：
  - `tenant_id`
  - channel
  - queue
  - conversation mode
  - severity
- 匹配输入只能来自 source-of-truth message text（事实源消息文本），不能来自模型生成的解释。

## Core Entities（核心实体）

### `InterventionRule`
- `tenant_id`
- `rule_id`
- `name`
- `enabled`
- `severity`
- `match_operator`
- `terms`
- `channel_scope`
- `queue_scope`
- `cooldown_window`
- `notify_policy_id`
- `enrichment_policy`
- `auto_actions`
- `version`

### `UrgentIntervention`
- `tenant_id`
- `intervention_id`
- `conversation_id`
- `trigger_message_id`
- `rule_id`
- `severity`
- `matched_terms`
- `status`
- `dedupe_key`
- `triggered_at`
- `last_matched_at`
- `ack_actor_id`
- `acked_at`
- `resolved_at`

### `NotificationEndpoint`
- `tenant_id`
- `endpoint_id`
- `provider_type`
- `channel_name`
- `secret_ref`
- `template_id`
- `enabled`
- `version`

### `NotificationDelivery`
- `tenant_id`
- `delivery_id`
- `intervention_id`
- `endpoint_id`
- `template_version`
- `enrichment_status`
- `status`
- `attempt_count`
- `last_error_code`
- `last_error_message`
- `last_attempted_at`
- `delivered_at`

## Notification Payload Rules（通知载荷规则）
- payload（载荷）可以包含：
  - tenant display name（租户显示名）
  - conversation id 或 console deep link（控制台深链）
  - severity
  - matched terms（命中词）
  - redacted message excerpt（脱敏消息摘录）
  - channel
  - queue
  - device snapshot（设备快照），如果可用
  - trigger time（触发时间）
- payload 不得包含：
  - secrets 或 tokens
  - raw provider credentials（原始供应商凭据）
  - 不必要的 customer PII
  - 默认情况下的完整会话转录（full conversation transcript）

## Device Enrichment Rules（设备补充信息规则）
- enrichment 只能使用已经附着在 conversation 或 message context 上的 trusted identifiers（可信标识）
- `routing-service` 只能在 intervention 创建之后调用 `device-service`
- enrichment timeout（补充信息超时）不能无限阻塞通知
- 如果 enrichment 失败或超时：
  - 通知仍然发送
  - delivery audit（投递审计）记录 `enrichment_status`
  - 同步 dispatch path（分发路径）里不允许隐藏重试循环

## Cooldown And Idempotency Rules（冷却与幂等规则）
- 重复投递的 `MessageAppended` 不能创建重复 intervention
- 在配置的 cooldown window（冷却窗口）内，同一 conversation + 同一 rule 的重复命中应复用活跃 intervention 记录
- notification dispatch（通知分发）必须按 `intervention_id + endpoint_id + template_version` 幂等
- consumer restart（消费者重启）后，所有 intervention events 和 deliveries 都必须 replay-safe（可重放）

## Operational Behavior（运行行为）
- notification provider failure（通知供应商失败）不能回滚 intervention record（介入记录）
- 失败通知必须异步重试，并显式推进 status transition（状态迁移）
- 永久失败必须在 console 和 audit 中保持可见
- 这个 workflow 在部分故障期间允许 lag（滞后），但不能拖慢 chat persistence（聊天持久化）或 realtime push（实时推送）

## Recommended Auto Actions（推荐自动动作）
- 添加 `urgent_intervention` 标签
- 提高 queue priority（队列优先级）或标记 supervisor visibility（主管可见性）
- 按需把后续任务分配到 management queue（管理队列）

除非 tenant policy（租户策略）明确开启，否则默认不要自动转接（auto-transfer）会话。

## Future Extensions（未来扩展）
- AI-assisted semantic risk classification（AI 辅助语义风险分类）作为补充信号
- OCR 或 ASR side-lane enrichment（旁路补充信息）
- 只有当 provider 数量、template 复杂度或 notification throughput（通知吞吐）真的支撑时，才拆独立 `notification-service`

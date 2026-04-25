# Multi-Tenant And Domain Model（多租户与领域模型）

## Tenant Model（租户模型）
- `tenant_id` 是 first-class system key（一级系统键），不是临时拼接、随手传递的普通字符串。
- Tenant context（租户上下文）只能来自 trusted resolution（可信解析）：
  - authenticated operator token（已认证操作员令牌）
  - verified channel binding（已验证渠道绑定）
  - trusted internal event envelope（可信内部事件信封）
- `TenantContext` 的正式冻结形状与 trusted resolution 规则见 `tenant-resolution-and-authorization-v1.md`。
- 缺少 tenant context 属于 hard failure（硬失败）。
- 生产环境不存在 `default tenant`。

## Identity And Roles（身份与角色）
- V1 的认证模型（authentication model）采用本地账号 + tenant-scoped RBAC（租户作用域角色权限）。
- operator console 使用 single-tenant session token（单租户会话令牌）；普通 operator surface 不允许客户端自报 `tenant_id`。
- 核心角色（core roles）包括：
  - `agent`
  - `supervisor`
  - `qa`
  - `tenant_admin`
  - `platform_admin`
- 角色只定义默认边界；真正授权判断以 explicit permission strings（显式权限字符串）为准。
- `platform_admin` 的操作必须显式建模，并单独写入审计（audit）。
- `platform_admin` 不复用 tenant-scoped operator APIs，详细边界见 `tenant-resolution-and-authorization-v1.md`。

## Conversation Model（会话模型）
- 核心聚合（core aggregates）包括：
  - `Conversation`
  - `Message`
  - `ConversationEvent`
  - `ConversationProjection`
- 会话模式（conversation modes）包括：
  - `Human`
  - `Copilot`
  - `Autopilot`
  - `Assist`
  - `HandoffPending`
- 消息类型（message types）包括：
  - `text`
  - `image`
  - `video`
  - `system`
  - `asset`
  - `link_card`

## Routing Model（路由模型）
- 核心路由实体（core routing entities）包括：
  - `ChannelGroup`
  - `Queue`
  - `QueueTicket`
  - `Assignment`
  - `Transfer`
  - `AgentPresence`
  - `InterventionRule`
  - `UrgentIntervention`
  - `ResponseTimeoutPolicy`
  - `ResponseTimeoutAlert`
- Routing rules（路由规则）按租户配置驱动。
- `Assist` 回复不会改变主负责客服（primary assigned agent）。
- `Transfer` 必须保留完整的 conversation 和 audit chain（审计链）。
- 非活跃自动下线（inactivity auto-offline）由 `routing-service` 持有，不允许只靠前端推断。

## Urgent Intervention Model（紧急介入模型）
- high-risk keyword monitoring（高风险关键词监控）由租户配置，并归 `routing-service` 持有。
- V1 的匹配必须是 deterministic（确定性）的，并且只对已提交的客户文本消息运行。
- intervention notification（介入通知）属于 side-lane effect（旁路副作用），不能阻塞 chat truth（聊天真相）或 realtime delivery（实时投递）。
- device enrichment（设备补充信息）是可选的，而且只能来自 trusted business facts（可信业务事实）。
- 每次 intervention 和 delivery attempt（投递尝试）都必须可审计、幂等（idempotent）、并带租户边界。

## Response Timeout Model（响应时限模型）
- assigned-human response-timeout monitoring（已分配人工会话响应超时监控）由租户配置，并归 `routing-service` 持有。
- policy resolution（策略解析）采用 tenant default（租户默认）+ exact queue override（精确队列覆盖）。
- timer（定时器）只能从已提交客户消息和 trusted assignment-effective time（可信分配生效时间）推导。
- 人类可见的客服回复、转接或会话关闭，都会清除当前 waiting state（等待状态）。
- 每个 waiting window（等待窗口）、timeout alert（超时告警）和 delivery attempt 都必须可审计、幂等并带租户边界。

## Media Model（媒体模型）
- 用户可发送（user can send）：
  - `text`
  - `image`
  - `video`
- AI 可理解（AI can understand）：
  - `text`
  - `image`
- AI 在 V1 不能理解（cannot understand）：
  - `video`
- Video policy（视频策略）固定为：
  - 总是持久化 metadata（元数据）和 preview path（预览路径）
  - 总是转人工（hand off to human）
  - 总是记录 `video_not_supported_in_v1` 作为原因

## Asset Library Model（素材库模型）
- fixed outbound assets（固定外发素材）按租户隔离。
- asset types（素材类型）包括：
  - `image`
  - `video`
  - `link_card`
- 每个 asset 必须携带：
  - `tenant_id`
  - `asset_type`
  - `business_tags`
  - `channel_support`
  - `review_status`
  - `effective_from`
  - `effective_to`
  - `version`
- AI 只能选择同时满足以下条件的素材：
  - tenant-visible（当前租户可见）
  - channel-compatible（渠道兼容）
  - reviewed（已审核）
  - currently effective（当前生效）

## Business Fact Boundaries（业务事实边界）
- Device、order、SIM、refund、after-sales facts 只有在 owned business APIs（自有业务 API）或 controlled tools（受控工具）返回时，才是 authoritative（权威事实）。
- AI 生成文本永远不能成为 device 或 order 状态的 source of truth（事实源）。
- Search projections（搜索投影）、analytics projections（分析投影）和 AI summaries（AI 摘要）都只是 derived data（派生数据）。

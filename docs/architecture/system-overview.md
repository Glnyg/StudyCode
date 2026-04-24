# System Overview（系统总览）

## Goal（目标）
构建一个 production-grade（生产级）的多租户（multi-tenant）便携 WiFi 客服系统，把人工客服工作流（human support workflows）与 AI assistance（AI 辅助）结合起来，同时不牺牲 tenant isolation（租户隔离）、auditability（可审计性）和 operational clarity（运维清晰度）。

## Product Scope（产品范围）
- 客户入口（customer entry）：
  - Enterprise WeChat（企业微信）客服渠道
  - official account（公众号）渠道
- 人工客服能力（human support）：
  - realtime chat（实时聊天）
  - routing（路由）
  - queueing（排队）
  - transfer（转接）
  - assist（辅助）
  - evaluation（评价）
  - quality inspection（质检）
  - performance analytics（绩效分析）
  - urgent manager intervention notification（紧急管理介入通知）
  - assigned-agent response-timeout alerting（已分配客服未回复超时告警）
- AI 支持能力（AI support）：
  - reply recommendation（回复建议）
  - autopilot replies（自动驾驶回复）
  - image-aware handling（图像感知处理）
  - controlled tool execution（受控工具调用）
  - knowledge retrieval（知识检索）
  - learning candidates（学习候选）
- 业务支持能力（business support）：
  - device information lookup（设备信息查询）
  - order / after-sales facts（订单与售后事实）
  - package recommendation（套餐推荐）

## Explicit Non-Goals For V1（V1 明确非目标）
- 不支持 tenant-specific custom code branches（租户专属代码分支）。
- 不支持 video understanding（视频理解）进入 AI hot path（热路径）。
- 不支持动态 image / video generation（动态图片或视频生成）。
- 不让 OpenSearch 持有 transactional truth（事务真相）。
- 不把 Kafka、ClickHouse 或独立 vector database（向量数据库）作为 day-one（第一天）强依赖。

## Architecture Principles（架构原则）
- 每个 request、event、cache key、search document、object key 都必须包含 trusted `tenant_id`。
- Realtime chat 是 hot path；AI、quality inspection、analytics、search indexing 都属于 side lanes（旁路通道）。
- PostgreSQL 是 messages、conversations、audit、AI configuration、knowledge metadata 的 source of truth。
- OpenSearch 只是 chat history search 的 derived read model（派生读模型）。
- AI 必须经过 explicit policy（显式策略）、explicit tools（显式工具）、explicit audit（显式审计）、explicit fallback（显式回退）。
- 凡是可能影响 routing、tenancy、billing、device operations 的行为，都必须 fail closed（拒绝）并 fail loudly（明确报错）。

## Top-Level Service Map（顶层服务图）
- Edge services（边缘服务）：
  - `api-gateway`
  - `realtime-gateway`
- Core business services（核心业务服务）：
  - `identity-service`
  - `channel-service`
  - `conversation-service`
  - `routing-service`
  - `media-service`
  - `search-service`
  - `knowledge-service`
  - `ai-service`
  - `device-service`
  - `analytics-service`

## Operating Model（运行模型）
- 外部流量先进入 `api-gateway`。
- 渠道 webhook（回调）由 `channel-service` 验签并归一化。
- Durable message / conversation state（持久会话与消息真相）由 `conversation-service` 持有。
- Queueing、assignment、transfer、agent state 由 `routing-service` 持有。
- 高风险介入规则（intervention rules）、response-timeout alerting、management alert dispatch 由 `routing-service` 持有。
- Realtime fan-out（实时分发）到客服和主管控制台由 `realtime-gateway` 负责。
- AI decisions、knowledge retrieval、controlled tool execution 由 `ai-service` 负责。
- Search projections（搜索投影）由 `search-service` 异步从 domain events 构建。

## Realtime And Performance Targets（实时与性能目标）
- Message ingress 到 agent push：
  - `p95 < 800ms`
  - `p99 < 2s`
- Agent outbound send 到 upstream accept：
  - `p95 < 1s`
- AI text 或 text+image assist response：
  - `p95 < 1.5s`
- 日常租户容量基线（daily tenant volume baseline）：
  - `700k` messages/day
  - `10x` traffic spike planning（10 倍突发规划）
  - `200+` concurrent online agents（同时在线客服）

## Delivery Stages（交付阶段）
1. 设计包（design package）和 ADR baseline（决策基线）。
2. 平台基线（platform baseline）与 shared contracts（共享合同）。
3. Realtime conversation loop（实时会话闭环）。
4. Search read-side 与客服搜索体验。
5. AI assist、图像处理、controlled tools。
6. Knowledge release、analytics、quality inspection。

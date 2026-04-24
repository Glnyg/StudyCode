# Verification Baseline（验证基线）

## Architecture Acceptance（架构验收）
- Service boundaries（服务边界）已经写清楚且无歧义。
- Source-of-truth stores（事实存储）与 derived stores（派生存储）分离明确。
- 每个 public contract 和 domain event 都有文档。

## Multi-Tenant Checks（多租户检查）
- missing tenant 必须 fail closed
- forged tenant access（伪造租户访问）必须 fail closed
- cross-tenant search 必须 fail closed
- cross-tenant asset 或 knowledge access 必须 fail closed

## Search Checks（搜索检查）
- keyword search（关键词搜索）
- highlight rendering（高亮渲染）
- time filtering（时间过滤）
- customer / agent / channel / queue filtering
- stable pagination（稳定分页）
- delayed projection consistency（延迟投影一致性）
- OpenSearch 挂掉时返回 explicit degraded-search error

## Realtime Checks（实时检查）
- `p95 < 800ms` ingress-to-push
- `p99 < 2s` ingress-to-push
- `200+` online agents
- queue transfer 和 assist actions 仍然保持 ordering（顺序）与 audit（审计）一致

## AI Checks（AI 检查）
- text request path
- text + image request path
- video 必须始终 routed to human（转人工）
- 只允许 fixed asset selection（固定资产选择）
- low-risk tool policy gating
- configuration publish / rollback traceability（发布与回滚可追踪）
- conversation-level AI replay

## Management Alert Checks（管理告警检查）
- 配置好的关键词命中会触发 urgent intervention
- 不匹配文本不会触发
- 已分配人工的会话，如果 `N` 分钟内没有人工回复，会触发一条 response-timeout alert
- deadline（截止时间）前有人工回复时，不会触发 response-timeout alert
- 没有 active human assignment（有效人工分配）时，不会触发 response-timeout alert
- transfer 会为新 assignee（接手人）重置 timeout window
- conversation close 会清理 pending waiting state，而不会额外发送新 alert
- cooldown window 防止同一 conversation 和 rule 重复告警
- duplicate delivery 或 worker restart 不会对同一 waiting round 发送重复 response-timeout notification
- device enrichment timeout 发生时，通知仍然发送，并带明确 fallback state
- urgent intervention acknowledgement 与 resolution 可审计
- response-timeout alert 的 clear reason 可审计
- Enterprise WeChat 或 Feishu provider failure 不会阻塞 chat flow

## Failure Drills（故障演练）
- RabbitMQ 单节点故障
- Redis 短暂不稳定
- OpenSearch 节点故障
- PostgreSQL failover
- realtime gateway rollout
- search projection rebuild
- live chat 期间单个 stateless service Pod 崩溃
- live chat 期间单个 worker-node 掉电
- websocket reconnect + 按 sequence replay
- worker restart 后 outbound retry 仍然无重复可见副作用

## Data Checks（数据检查）
- PostgreSQL partition pruning 对时间范围聊天查询生效。
- OpenSearch retention policies 与 365 天在线目标一致。
- Search hit links 始终能回放到正确的 source-of-truth conversation。

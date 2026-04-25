# TenantContext

## 它是什么
- `TenantContext` 是服务端已经确认过、可以被业务逻辑信任的租户上下文。

## 为什么重要
- 它把“客户端说自己是谁”变成“系统确认它是谁”，是 [[租户隔离]] 的实际承载物。

## 本项目怎么用
- `TenantContext` 只允许来自 [[Tenant Resolution]] 的可信结果：
  - `token`
  - `channel_binding`
  - `internal_event`
  - `platform_admin_scope`

## 工作里怎么落地
- 业务代码、搜索读侧、AI 决策、素材访问和审计记录，都应该消费 `TenantContext`，而不是消费松散的 `tenant_id` 字符串。

## 面试里怎么表达
- “我会先把 trusted tenant resolution 的结果落成 `TenantContext`，再让后面的 repository、service、event consumer 统一依赖它，而不是让每层自己猜租户。”

## 你下一步应该看什么
1. [[Tenant Resolution]]
2. [[多租户]]
3. [[02-Domain/租户解析与授权冻结包 V1|租户解析与授权冻结包 V1]]

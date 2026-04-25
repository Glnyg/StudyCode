# Tenant Resolution And Authorization V1（租户解析与授权 V1）

## Goal（目标）
- 把 trusted tenant resolution（可信租户解析）、authorization（授权）和 privileged admin boundary（特权管理边界）冻结成 implementation-ready baseline（实现就绪基线）。
- 让后续实现不再临场发明 token claims、`TenantContext`、permission strings、`401/403/404` 语义或 `platform_admin` 越权路径。
- 这份文档是 `ADR 0005` 与 `Contract Package V1` 的细化，不重新打开多租户方向争论。

## Scope（范围）
- 包含：
  - operator console（坐席工作台）请求的 trusted tenant resolution
  - Enterprise WeChat customer-service webhook（企业微信客服回调）的 trusted tenant resolution
  - internal event（内部事件）的 trusted tenant resolution
  - single-tenant operator session token（单租户操作员会话令牌）claims shape
  - tenant-scoped RBAC（租户作用域角色权限）和 canonical permission strings（规范权限字符串）
  - `platform_admin` 的显式 admin surface（管理面）边界
  - audit 和错误语义
- 不包含：
  - SSO / OIDC
  - 登录 UX（交互体验）
  - user provisioning（用户开通）
  - 完整 upstream integration freeze（外部集成冻结）

## Freeze Decisions（冻结决策）

### 1. Trusted Tenant Resolution Paths（可信租户解析路径）

| 入口 | 唯一可信来源 | 解析结果 | fail-closed 规则 |
| --- | --- | --- | --- |
| operator console | `Authorization` bearer token claims | trusted `TenantContext` + `UserContext` | token 缺失、无效、过期或无 `tenant_id` 时直接拒绝 |
| Enterprise WeChat webhook | verified signature + verified channel binding | trusted `TenantContext` | 验签失败、binding 缺失或 binding 指向其他租户时直接拒绝 |
| internal event | trusted event envelope（含 `tenant_id`、`producer`、`correlation_id`） | trusted `TenantContext` | `tenant_id` 缺失、producer 不可信或 envelope 不完整时不执行业务副作用 |

### 2. Operator Console Token Model（操作员令牌模型）
- operator console 统一使用 single-tenant session token（单租户会话令牌）。
- 一个 token 在任意时刻只允许绑定一个 active `tenant_id`。
- 普通 operator surface（操作员接口面）不支持在 header、query、body 中传可伪造的 `tenant_id`。
- token claims 冻结为：

| Claim | 含义 | 规则 |
| --- | --- | --- |
| `sub` | actor identity（操作者身份） | 映射到 `UserContext.actor_id` |
| `tenant_id` | active tenant（当前活跃租户） | 映射到 `TenantContext.tenant_id` |
| `actor_type` | actor type（操作者类型） | 只能是已冻结角色类型 |
| `role` | primary RBAC role（主角色） | 用于审计和权限基线 |
| `permissions` | explicit action permissions（显式动作权限） | 真正授权判断以它为准 |
| `session_id` | auditable session key（可审计会话键） | 所有 privileged writes（特权写操作）必须落审计 |

### 3. TenantContext And UserContext（租户与用户上下文）
- `TenantContext` 只允许来自：
  - `token`
  - `channel_binding`
  - `internal_event`
  - `platform_admin_scope`
- `UserContext` 只允许基于显式 `permissions` 做授权判断，不能从：
  - 前端按钮状态
  - UI route（界面路由）
  - 模糊角色名映射
  - “这个人通常能做这个事”的隐式经验
- `TenantContext`、`UserContext` 和 `OperatorTokenClaims` 的机器可读形状由 `docs/api/contract-package-v1/schemas/shared-types.schema.json` 冻结。

### 4. Canonical Permission Strings（规范权限字符串）
- 当前冻结的 canonical permission strings（规范权限字符串）包括：
  - `conversation.read`
  - `conversation.reply`
  - `conversation.evaluate`
  - `conversation.assign`
  - `conversation.transfer`
  - `routing.queue.read`
  - `routing.presence.write`
  - `routing.rule.read`
  - `routing.rule.write`
  - `routing.alert.read`
  - `routing.alert.manage`
  - `search.read`
  - `media.asset.read`
  - `media.asset.write`
  - `media.review`
  - `ai.suggestion.read`
  - `ai.decision.execute`
  - `ai.audit.read`
  - `ai.policy.read`
  - `ai.policy.publish`
  - `tenant.config.write`
- 所有 tenant-scoped operator OpenAPI surface 都必须用 `x-required-permissions` 标明所需 permission。

### 5. Tenant-Scoped RBAC Matrix（租户作用域权限矩阵）

| Role | 最低权限集合 |
| --- | --- |
| `agent` | `conversation.read`, `conversation.reply`, `conversation.evaluate`, `routing.presence.write`, `search.read`, `media.asset.read`, `ai.suggestion.read`, `ai.decision.execute` |
| `supervisor` | `agent` 全部权限，加 `routing.queue.read`, `conversation.assign`, `conversation.transfer`, `routing.rule.read`, `routing.alert.read`, `routing.alert.manage`, `media.review`, `ai.audit.read`, `ai.policy.read` |
| `qa` | `conversation.read`, `search.read`, `media.asset.read`, `ai.audit.read`, `ai.policy.read` |
| `tenant_admin` | `supervisor` 全部权限，加 `routing.rule.write`, `media.asset.write`, `ai.policy.publish`, `tenant.config.write` |

- `platform_admin` 不复用上表，不允许直接拿 tenant-scoped operator token 调 tenant-owned operator APIs。

### 6. Platform Admin Boundary（平台管理员边界）
- `platform_admin` 必须走显式 admin surface（管理面），不能直接复用：
  - `/v1/conversations*`
  - `/v1/search*`
  - `/v1/assets*`
  - `/v1/ai/*`
  - `/v1/realtime/bootstrap`
- admin surface 必须满足：
  - 目标租户显式出现，优先放在 path，例如 `/v1/admin/tenants/{tenant_id}/...`
  - 请求带可审计 `session_id`
  - 请求带 operator reason / change reason（操作原因）
  - 请求带 `X-Correlation-Id`
- 缺少 explicit target tenant（显式目标租户）或 audit metadata（审计元数据）的 admin 请求必须 fail closed。

### 7. Operator/Public HTTP Response Policy（操作员/公共 HTTP 响应策略）
- operator/public HTTP surface 默认使用真实 HTTP status + 统一 error envelope（错误信封）。
- 以下失败不允许使用外层 `200` 包装真实失败：
  - authentication（认证）失败
  - tenant resolution / tenant boundary（租户解析 / 租户边界）失败
  - permission / admin boundary（权限 / 管理员边界）失败
  - request-shape / validation（请求形状 / 校验）失败
  - conflict / not-found / dependency / internal failure（冲突 / 不存在 / 依赖 / 内部失败）
- 外层 `200` 只允许用于“HTTP 成功返回业务状态报告对象”的场景；当前 tenant-scoped operator surfaces 不新增这种包装错误。
- `GET` 请求不接受 request body（请求体），也不定义 body 语义。
- 如果客户端给 `GET` 发送 body，必须返回 `400` request-shape violation（请求形状违规）：
  - edge / gateway 在进入 owning service 前拒绝时，使用 `gateway.request_invalid`
  - owning service 在解析 query / payload 语义时拒绝时，使用 `<service>.invalid_request`
- operator/public 错误诊断顺序固定为：
  - 先看 HTTP status
  - 再看 `error_source`
  - 最后看 `code`

### 8. Status Code Semantics（状态码语义）
- `400`：
  - malformed admin request（格式错误的管理请求）
  - unsupported `GET` request body（不支持的 `GET` 请求体）
  - malformed query / payload shape（格式错误的 query / payload）
  - 如果拒绝发生在 edge / gateway，使用 `gateway.request_invalid`、`gateway.target_tenant_required`、`gateway.audit_metadata_required`
  - 如果拒绝发生在 owning service，使用 `<service>.invalid_request` 或更具体的 domain code
- `401`：
  - 身份无效、过期、缺失
  - webhook signature 不可验证
  - 在 trusted `TenantContext` 建立之前就失败
  - 这些错误码必须使用 `gateway.*`
- `403`：
  - token 有效，但 tenant scope 不匹配
  - permission 不足
  - `platform_admin` 试图走 tenant-scoped operator surface
  - webhook binding 指向不允许的 tenant
  - 如果拒绝发生在 edge / gateway，使用 `gateway.*`
  - 如果拒绝发生在 owning service，使用 `<service>.permission_denied` 或 `tenant.*`
- `404`：
  - 对 tenant-owned resource（租户拥有资源）隐藏 cross-tenant existence（跨租户存在性）
  - 例如 `conversation.not_found`、`media.asset_not_found`
- `409`：
  - state conflict（状态冲突）
  - stale version（过期版本）
  - invalid replay position（非法重放位置）
  - idempotency payload mismatch（幂等载荷不匹配）
  - 这类失败也必须直接返回真实 `409`，不能外包成 `200`
- `503` / `5xx`：
  - dependency degraded（依赖降级）
  - upstream unavailable（上游不可用）
  - unexpected internal failure（意外内部失败）
  - 这类失败必须直接返回真实 `5xx`，并继续通过 `error_source` + `code` 区分 owner

### 9. Audit Requirements（审计要求）
- privileged operations（特权操作）最少必须记录：
  - `session_id`
  - `actor_id`
  - `role`
  - resolved `tenant_id`
  - `target_tenant_id`（如果是 `platform_admin`）
  - `correlation_id`
  - `reason`
  - operation name（操作名）
- 审计判断以服务端解析后的 `TenantContext` / `UserContext` 为准，不记录客户端自报租户。

## Positive And Negative Examples（正例与负例）

### Operator Console（操作员工作台）
- 正例：
  - bearer token claims 为 `sub=agent-001`, `tenant_id=tenant-a`, `actor_type=agent`, `role=agent`, `permissions=["conversation.read","conversation.reply"]`, `session_id=sess-001`
  - 服务端解析出 `TenantContext { tenant_id = tenant-a, resolution_source = token }`
- 负例：
  - missing / invalid token：
    - `401 gateway.identity_invalid`
  - `GET /v1/conversations` 携带 request body：
    - `400 gateway.request_invalid`
  - token 属于 `tenant-a`，但请求命中 `tenant-b` 的 conversation：
    - `404 conversation.not_found`
  - valid token 但缺少 `conversation.reply` 却调用发送消息接口：
    - `403 conversation.permission_denied`
  - `platform_admin` token 直接调用 operator API：
    - `403 gateway.admin_surface_required`

### Enterprise WeChat Webhook（企业微信客服回调）
- 正例：
  - signature 验证成功，channel binding 把 webhook app 解析到 `tenant-a`
  - 服务端构造 `TenantContext { tenant_id = tenant-a, resolution_source = channel_binding }`
- 负例：
  - signature 无法验证：
    - `401 gateway.signature_invalid`
  - binding 缺失或命中错误租户：
    - `403 gateway.channel_binding_mismatch`

### Internal Event（内部事件）
- 正例：
  - event envelope 带 `tenant_id=tenant-a`, `producer=conversation-service`, `correlation_id=corr-001`, `payload_version=1`
  - consumer 通过 trusted producer allowlist（可信生产者白名单）校验后执行业务逻辑
- 负例：
  - envelope 缺少 `tenant_id`：
    - 拒绝消费，不产生业务副作用，记录 `internal.tenant_context_missing`
  - envelope 的 `producer` 不在 allowlist：
    - 拒绝消费，不产生业务副作用，记录 `internal.untrusted_event_producer`

### Platform Admin（平台管理员）
- 正例：
  - `platform_admin` 通过显式 admin surface 对 `tenant-a` 执行受控操作，并写入 `session_id`、`reason`、`correlation_id`
- 负例：
  - 没有显式 `target_tenant_id`：
    - `400 gateway.target_tenant_required`
  - 没有审计原因：
    - `400 gateway.audit_metadata_required`

## Contract Package Alignment（与合同包的对齐）
- `Contract Package V1` 必须同步反映这份冻结文档的以下结果：
  - `OperatorTokenClaims`
  - `TenantContext` / `UserContext`
  - `x-required-permissions`
  - `401/403/404` 语义
  - multi-tenant negative cases（多租户负例）
- 如果未来变更涉及：
  - claims shape
  - trusted resolution source
  - `platform_admin` boundary
  - canonical permission strings
  - cross-tenant hiding semantics
  就必须同步更新本文件和 `docs/api/contract-package-v1/`。

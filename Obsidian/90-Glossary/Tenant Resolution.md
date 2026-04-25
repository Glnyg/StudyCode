# Tenant Resolution

## 它是什么
- `Tenant Resolution` 指的是：系统如何把一次请求、一次回调或一条内部事件，解析成可信的租户身份。

## 为什么重要
- 如果这一步不可信，后面的 [[TenantContext]]、[[RBAC]]、[[租户隔离]] 和 [[审计]] 都会失真。

## 本项目怎么用
- 普通业务入口只允许 3 条可信来源：
  - operator token
  - verified channel binding
  - trusted internal event
- 如果是显式 admin surface（管理面），还允许把目标租户解析成 `platform_admin_scope`，但它不能伪装成普通 tenant-scoped operator API。

## 工作里怎么落地
- 每个入口都要有唯一的 trusted resolution rule（可信解析规则），不能一会儿看 token，一会儿看 query，一会儿猜默认租户。

## 面试里怎么表达
- “多租户系统里，tenant 不是普通字符串参数，而是要先经过 trusted tenant resolution，再进入业务逻辑。”

## 你下一步应该看什么
1. [[TenantContext]]
2. [[多租户]]
3. [[02-Domain/租户解析与授权冻结包 V1|租户解析与授权冻结包 V1]]

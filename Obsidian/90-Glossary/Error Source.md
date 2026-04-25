# Error Source

## 它是什么
- `Error Source` 指的是：一次错误到底是发生在 edge / gateway 前置阶段，还是发生在 owning service（拥有该资源的服务）、domain policy（领域策略）、dependency（依赖）或内部处理阶段。

## 为什么重要
- 同样都是 `401`、`403` 或 `503`，如果不知道错误归属，排障路径会很长。
- 在多租户系统里，gateway reject（网关拒绝）和 system reject（系统拒绝）常常代表完全不同的修复方向。

## 本项目怎么用
- `error_source = gateway`：
  - 表示 API Gateway、edge boundary 或 trusted tenant resolution 前置阶段就已经拒绝。
  - 这类错误通常配 `gateway.*`。
- `error_source = system`：
  - 表示 owning service、domain policy、dependency access 或内部处理阶段出的错。
  - 这类错误必须用 service / domain / dependency 前缀，不能继续冒充 `gateway.*`。
- `Error Source` 是和真实 [[HTTP 状态码语义]] 一起用的，不是拿来代替状态码的。

## 工作里怎么落地
- 做 review 时，先问：
  - 这个错误是在请求进入 owning service 之前就能决定吗？
  - 如果不是，为什么还在用 `gateway.*`？
- 做 incident 排障时，把 `status -> Error Source -> code` 当成固定读取顺序。

## 面试里怎么表达
- “我会把 transport 大类交给 HTTP status，把错误归属交给 `error_source`，再用业务 `code` 定位具体规则，这样 gateway 和 system 的责任边界很清楚。”

## 你下一步应该看什么
1. [[HTTP 状态码语义]]
2. [[Tenant Resolution]]
3. [[TenantContext]]

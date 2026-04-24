# Test Strategy And Quality Gates（测试策略与质量闸门）

## Goal（目标）
定义本仓库里“tests have guarantees（测试具备保证）”到底是什么意思。

## Principle（原则）
只有当 changed area（变更区域）被正确测试层（correct test layer）保护时，passing test suite（通过的测试套件）才有意义。

## Mandatory Test Layers By Change Type（按变更类型要求的测试层）

### Core Domain Change（核心领域变更）
例如：
- conversation mode transition
- queue assignment rule
- transfer invariant
- knowledge release visibility

必需：
- domain invariant tests
- 至少一个 application-service 或 integration path

### Workflow / Orchestration Change（工作流 / 编排变更）
例如：
- channel webhook handling
- AI orchestration step ordering
- device command flow
- urgent intervention notification flow
- response-timeout alert scheduling and dispatch

必需：
- application-service tests
- integration 或 contract tests
- 涉及 retry 的地方要有 idempotency / replay coverage

### Search Change（搜索变更）
例如：
- search mapping
- query filter logic
- projection builder changes

必需：
- projection tests
- query behavior tests
- rebuild 或 replay coverage

### AI Policy Change（AI 策略变更）
例如：
- prompt selection
- tool policy
- asset policy
- fallback behavior

必需：
- policy decision tests
- fallback tests
- audit completeness tests

### Public Contract Change（公共合同变更）
例如：
- HTTP API shape
- gRPC contract
- domain event schema

必需：
- contract tests
- 文档中的 migration 或 compatibility notes

## Quality Gates（质量闸门）
- 能自动化验证的改动，不应只依赖 manual testing（手工测试）就进入 merge-ready 状态。
- 对 routing、AI policy、multi-tenant logic 来说，只测 happy path 远远不够。
- Multi-tenant changes 必须覆盖：
  - missing tenant
  - wrong tenant
  - cross-tenant attempt
- Replay-sensitive changes 必须覆盖：
  - duplicate delivery test
  - retry after partial failure test

## Minimal Acceptance For “Tested”（“已测试”最低标准）
- 至少有一个 test 在改动前会失败、改动后会通过。
- 这个 test 作用于风险最高的那一层。
- test name 或 scenario 要表达业务规则，而不是只表达实现细节。

## Anti-Patterns（反模式）
- 用 smoke test 代替 domain rule test
- 只用 controller tests 验证 domain invariants
- 对 retry、replay、integration behavior 只依赖 mocked unit tests
- 用无关的大而全测试套件来宣称 coverage

## Release-Critical Paths（发布关键路径）
以下路径需要尤其强的覆盖：
- inbound message durability
- outbox / inbox replay
- queue assignment 与 transfer
- urgent intervention 的 trigger、dedupe、notification retry
- response-timeout window creation、clear semantics、dedupe、notification retry
- AI tool gating
- tenant isolation
- search projection rebuild
- websocket reconnect and replay

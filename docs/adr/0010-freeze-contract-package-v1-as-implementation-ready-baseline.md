# ADR 0010：冻结 Contract Package V1 作为实现就绪基线

## Status（状态）
Accepted（已接受）

## Context（背景）
仓库已经有较完整的 blueprint-level（蓝图层）设计，覆盖了 service boundaries、tenant isolation、reliability、AI policy 和 search architecture。真正还缺的是一个 machine-readable（机器可读）的合同基线：
- shared request / event conventions
- 具体 HTTP API schemas
- 具体 event schemas
- error envelope 与 error-code rules
- idempotency、optimistic concurrency、replay、compatibility rules

如果没有这些产物，多名实现者或多个 AI agents 就会各自发明：
- 不同的 headers 和 error formats
- 不同的 replay semantics
- 不同的 idempotency assumptions
- 不同的 event field shapes

这样在第一个里程碑开始前，就会出现 contract drift（合同漂移）。

## Decision（决策）
- 冻结 `docs/api/contract-package-v1/` 作为 V1 的 implementation-ready contract baseline。
- `docs/api/public-contracts-and-events.md` 保留为入口索引和 workflow guide，而不是唯一细节文档。
- HTTP contracts 统一采用 `OpenAPI 3.1`。
- event 与 shared payload contracts 统一采用 `JSON Schema Draft 2020-12`。
- 冻结以下 shared rules：
  - trusted tenant context
  - correlation 与 trace propagation
  - `Idempotency-Key`
  - `If-Match`
  - error envelope
  - `search_after`
  - `last_seen_sequence`
  - event envelope 与 compatibility policy
- 在未来的 design freeze 明确写出以下信息之前，不新增 `.proto` 文件：
  - owning service
  - consuming service
  - RPC surface
  - idempotency 与 recovery semantics

## Consequences（影响）
- 未来只要 public APIs 或 event contracts 变化，就必须先更新 `contract-package-v1/`。
- downstream service teams 和 AI agents 有了统一的 machine-readable source，可用于 DTO generation 和 contract tests。
- replay、idempotency、cross-tenant safety rules 变成显式合同资产，而不再依赖聊天记忆。
- `gRPC` 仍然原则上允许，但不会靠猜测冻结。
- breaking contract changes 现在必须有显式 ADR 和 migration notes，不能再静默漂移。

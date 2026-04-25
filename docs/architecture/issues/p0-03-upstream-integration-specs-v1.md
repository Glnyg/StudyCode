# P0-03 Upstream Integration Specs V1

## Goal（目标）
冻结 `channel-service`、`device-service` 和管理通知 provider（通知提供方）依赖的上游集成协议、重试语义、幂等策略、媒体流转和 partial failure recovery（部分失败恢复）规则。

## Why This Blocks Coding（为什么阻塞编码）
- 这是本系统和外部世界接触最深的部分，错误不在于“连不上”，而在于 duplicate delivery（重复投递）、partial failure（部分失败）和补偿语义不清。
- 如果没有上游语义冻结，adapter code 会把 provider-specific behavior（供应商特有行为）散落在实现里。

## Scope（范围）
- Enterprise WeChat customer-service webhook contract（企业微信客服回调）
- official-account callback contract（公众号回调）
- upstream retry / duplicate-delivery semantics
- media callback / media fetch / asset ingest flow
- outbound send contract、provider acknowledgement model 和 provider idempotency strategy
- device / order / after-sales upstream API mapping
- reconciliation / compensation / operator-visible error semantics

## Non-Goals（非目标）
- 不在本议题里实现 adapter、SDK wrapper 或 anti-corruption layer 代码。
- 不重开 trusted tenant resolution 的原则；这里只冻结它在上游集成里的具体落地方式。
- 不在本议题里补齐内部数据库 schema；那属于 `PostgreSQL Detailed Schema V1`。

## Affected Paths（影响路径）
- [docs/architecture/implementation-readiness-and-design-freeze.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-readiness-and-design-freeze.md)
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/domain/tenant-resolution-and-authorization-v1.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/tenant-resolution-and-authorization-v1.md)
- [docs/reliability/power-loss-and-recovery.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/reliability/power-loss-and-recovery.md)
- [docs/domain/urgent-intervention-and-management-alerting.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/urgent-intervention-and-management-alerting.md)
- [docs/domain/response-timeout-alerting.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/response-timeout-alerting.md)
- 预期新增的 upstream integration freeze 文档或其等价文档

## Constraints（约束）
- tenant 必须来自 trusted resolver（可信解析器），不能从 spoofable client input（可伪造输入）猜。
- 所有 webhook、callback、retryable jobs 都必须 replay-safe（可重放）并具备幂等语义。
- partial failure 不能引入 silent fallback（静默兜底）或重复对用户可见的副作用。
- provider failure 不能阻塞 chat durability 或 realtime delivery hot path。

## Suggested Delivery Order（建议顺序）
1. 先定 webhook / callback 合同和 tenant-safe normalization 规则。
2. 再定 outbound send、provider ack、retry / dedupe / idempotency 语义。
3. 最后定 media flow、device/order/after-sales mapping 和 compensation / reconciliation。

## Acceptance Checks（验收检查）
- 已形成一份权威 upstream integration 文档，能回答每个入口“怎么验签、怎么归一化、怎么 dedupe、怎么补偿、怎么对账”。
- 企业微信与公众号的 callback 语义已冻结到可以直接写 adapter tests 的粒度。
- outbound send 的 provider acknowledgement、retry、idempotency 和 user-visible side effects 已明确。
- device / order / after-sales 的字段映射与 anti-corruption boundary 已明确，不依赖运行时猜测。
- 文档与 tenant/auth、recovery、alerting 规则一致。

## References（参考）
- [implementation-readiness-and-design-freeze.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-readiness-and-design-freeze.md)
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [tenant-resolution-and-authorization-v1.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/tenant-resolution-and-authorization-v1.md)
- [power-loss-and-recovery.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/reliability/power-loss-and-recovery.md)

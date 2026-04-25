# P1-05 Intervention And Notification Freeze Package

## Goal（目标）
冻结 urgent intervention（紧急介入）与 response-timeout alerting（响应超时告警）相关的 rule schema、severity、cooldown/dedupe、notification endpoint、payload redaction、ack / resolve workflow 以及 provider retry / dead-letter 规则。

## Must Be Frozen By（最晚冻结时间）
在启动 intervention / timeout alerting 的深度实现、provider integration 和故障演练前完成。

## Scope（范围）
- intervention rule schema 与 severity model
- cooldown 与 dedupe rules
- management notification endpoint model 与 secret-reference rules
- payload templates 与 redaction rules
- acknowledgement 与 resolution workflow
- device-enrichment timeout 与 fallback rules
- provider retry 与 dead-letter runbook

## Non-Goals（非目标）
- 不重开“urgent intervention 与 response-timeout 由 routing-service 持有”的已冻结决策。
- 不在本议题里实现 provider adapters 或 alerting workers 代码。
- 不把 search、AI 或 general observability 议题混入这里。

## Affected Paths（影响路径）
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/domain/urgent-intervention-and-management-alerting.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/urgent-intervention-and-management-alerting.md)
- [docs/domain/response-timeout-alerting.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/response-timeout-alerting.md)
- [docs/api/contract-package-v1/routing-and-alerting-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/routing-and-alerting-pack.md)

## Constraints（约束）
- intervention 和 notification side effects 必须保持 asynchronous side-lane 属性，不能阻塞主聊天热路径。
- dedupe、cooldown、ack / resolve 语义必须 tenant-safe、replay-safe、audit-safe。
- payload templates 和 redaction rules 不能泄露 secrets 或 customer PII。
- device enrichment 失败时必须有明确 timeout / fallback 规则，不能静默卡住整个通知链路。

## Acceptance Checks（验收检查）
- 已明确 intervention rule 和 response-timeout policy 的字段级冻结范围。
- 已明确 cooldown、dedupe、acknowledge、resolve 和 notification dispatch 的语义。
- 已明确 endpoint model、secret references、payload templates 和 redaction 规则。
- 已明确 enrichment timeout、provider retry、dead-letter 和 runbook 的最小要求。
- 文档与 routing contract、recovery 规则和多租户边界一致。

## References（参考）
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [urgent-intervention-and-management-alerting.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/urgent-intervention-and-management-alerting.md)
- [response-timeout-alerting.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/domain/response-timeout-alerting.md)
- [routing-and-alerting-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/routing-and-alerting-pack.md)

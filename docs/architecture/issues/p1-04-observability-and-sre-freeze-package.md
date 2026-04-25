# P1-04 Observability And SRE Freeze Package

## Goal（目标）
冻结关键服务的 SLO、alerts、dashboards、trace requirements 和 failure-drill scripts，确保系统在进入更深实现阶段前具备可观测性和运维落地约束。

## Must Be Frozen By（最晚冻结时间）
在 search、routing、AI、notification workers 等关键路径进入联调或预生产演练前完成。

## Scope（范围）
- service SLOs
- latency / error / saturation alerts
- dashboards 与 trace requirements
- failure-drill scripts
- ownership model

## Non-Goals（非目标）
- 不在本议题里搭建全部监控基础设施。
- 不重开是否使用 OpenTelemetry、Prometheus、Grafana 等平台基线决策。
- 不把业务 contract 设计问题混入 observability 议题。

## Affected Paths（影响路径）
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/platform/k8s-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/platform/k8s-baseline.md)
- [docs/testing/verification-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/testing/verification-baseline.md)

## Constraints（约束）
- logs、traces、metrics 至少要能关联 `tenant_id`、`conversation_id`、`correlation_id`、`message_id` 和必要的 tool / alert identifiers。
- 可观测性不能泄露 secrets、tokens 或 customer PII。
- 失败演练必须对齐 power-loss / recovery 文档里的恢复语义，而不是自创恢复假设。

## Acceptance Checks（验收检查）
- 已明确每个关键 service 的 SLO 和基础 alert 策略。
- 已明确哪些 dashboard 和 trace fields 是上线前必须具备的。
- 已明确 failure drills 的最小剧本、责任人和通过标准。
- 文档与 k8s baseline、verification baseline 和 hot-path / side-lane 规则一致。

## References（参考）
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [k8s-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/platform/k8s-baseline.md)
- [verification-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/testing/verification-baseline.md)

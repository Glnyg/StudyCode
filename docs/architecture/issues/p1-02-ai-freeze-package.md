# P1-02 AI Freeze Package

## Goal（目标）
冻结 `ai-service` 的 policy/config schema、publish/rollback workflow、prompt assembly、tool manifest、audit payload 和 evaluation metrics，确保 AI 实现遵守明确的 policy-controlled design（策略受控设计）。

## Must Be Frozen By（最晚冻结时间）
在启动 `ai-service` 的 policy store、orchestrator、tool executor 和 evaluation 流程实现前完成。

## Scope（范围）
- policy / config schema fields
- publish / rollback workflow
- prompt assembly rules
- tool manifest format
- audit payload schema
- evaluation metric definitions

## Non-Goals（非目标）
- 不重开 AI service boundary、tool gating 原则或 V1 multimodal 边界。
- 不在本议题里调优具体 model prompts 或 provider SDK 代码。
- 不引入未经正式设计支持的新自动高风险工具执行路径。

## Affected Paths（影响路径）
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/ai/ai-service-design.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/ai/ai-service-design.md)
- [docs/ai/knowledge-rag-design.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/ai/knowledge-rag-design.md)
- [docs/api/contract-package-v1/ai-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/ai-pack.md)
- [docs/api/contract-package-v1/openapi/ai-service.openapi.yaml](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/openapi/ai-service.openapi.yaml)

## Constraints（约束）
- AI policy truth 必须在 PostgreSQL 中保持 authoritative。
- policy load failure 必须 fail closed。
- HighRiskMutating tools 不能自动执行。
- audit schema 必须覆盖 tenant、conversation、policy version、prompt version、tool calls、asset choice、fallback reason。

## Acceptance Checks（验收检查）
- 已明确 AI policy/config 的字段级 schema 和版本流转语义。
- 已明确 publish / rollback workflow 和 operator-visible concurrency / approval 规则。
- 已明确 prompt assembly 输入、优先级和 fallback 规则。
- 已明确 tool manifest 的最小字段集、allowlist / gating 约束和 idempotency 要求。
- 已明确 evaluation 指标定义，避免后续实现阶段临时发明“评估标准”。

## References（参考）
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [ai-service-design.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/ai/ai-service-design.md)
- [knowledge-rag-design.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/ai/knowledge-rag-design.md)
- [ai-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/ai-pack.md)

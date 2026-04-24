# ADR 0004：将 AI 标准化到抽象层与版本化策略模型之后

## Status（状态）
Accepted（已接受）

## Context（背景）
系统需要 model portability（模型可迁移性）、tenant-level AI configuration（租户级 AI 配置）、controlled tool execution（受控工具执行）和可审计 fallback。

## Decision（决策）
- `ai-service` 在应用边界（application boundary）使用 `Microsoft.Extensions.AI` abstractions。
- Provider SDKs 保持在 model gateway 后面。
- Prompt、reply、tool、asset、tenant AI settings 都版本化保存在 PostgreSQL，并通过显式 lifecycle states（生命周期状态）发布。

## Consequences（影响）
- Business logic 不会直接被 provider churn（供应商变化）冲击。
- AI behavior changes 必须经过 configuration publication（配置发布）和 audit。
- 未审核的 prompt 或 tool changes 不允许静默上线。

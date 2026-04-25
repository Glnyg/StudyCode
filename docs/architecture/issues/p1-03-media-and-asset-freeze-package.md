# P1-03 Media And Asset Freeze Package

## Goal（目标）
冻结媒体处理、审核状态、素材治理、URL signing（签名 URL）和 preview（预览）规则，确保 `media-service` 和 AI / operator surfaces 对 asset 的使用一致且可审计。

## Must Be Frozen By（最晚冻结时间）
在启动 `media-service` 的 media-processing jobs、asset governance 和 preview delivery 相关实现前完成。

## Scope（范围）
- media-processing job contract
- virus scan 与 moderation states
- asset review workflow
- URL signing 与 preview rules

## Non-Goals（非目标）
- 不在本议题里实现对象存储接入代码或媒体处理流水线。
- 不重开 V1 对视频理解进入 AI hot path 的非目标约束。
- 不在这里定义 AI policy 字段；那属于 `AI Freeze Package`。

## Affected Paths（影响路径）
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/api/contract-package-v1/media-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/media-pack.md)
- [docs/api/contract-package-v1/openapi/media-service.openapi.yaml](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/openapi/media-service.openapi.yaml)
- [docs/api/contract-package-v1/schemas/asset-ai-events.schema.json](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/schemas/asset-ai-events.schema.json)

## Constraints（约束）
- secrets、tokens、PII 和敏感媒体摘要不能以 plaintext logs 方式暴露。
- AI outbound 只能使用 reviewed fixed assets（已审核固定素材）。
- 视频消息在 V1 必须保留 metadata 并路由给人工，不能直接进入 AI hot path。
- preview / signed URL 规则必须 tenant-safe，并明确有效期与访问边界。

## Acceptance Checks（验收检查）
- 已明确 media job contract 的输入、输出、状态迁移和幂等语义。
- 已明确 virus scan / moderation states 和资产可见性之间的关系。
- 已明确 asset review workflow 的角色、状态、审计字段和失效语义。
- 已明确 preview / URL signing 的访问约束、过期时间和错误语义。

## References（参考）
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [media-pack.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/media-pack.md)
- [media-service.openapi.yaml](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/api/contract-package-v1/openapi/media-service.openapi.yaml)

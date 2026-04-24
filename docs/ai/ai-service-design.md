# AI Service Design（AI 服务设计）

## Role Of AI Service（AI 服务定位）
`ai-service` 是一个 policy-controlled decision layer（策略控制的决策层），不是随意拼在平台旁边的 free-form chatbot（自由聊天机器人）。

## Internal Modules（内部模块）
- `orchestrator`：为每次 AI 请求选择 execution path（执行路径）
- `rag`：检索 evidence（证据）并组装 grounded context（有依据的上下文）
- `tool-executor`：调用 controlled business tools（受控业务工具）
- `policy-engine`：决定某个 tenant 和场景下 AI 被允许做什么
- `prompt-config`：解析已发布的 prompt profile（提示词配置）和 prompt fragments（提示片段）
- `evaluation`：保存并暴露 quality / safety metrics（质量与安全指标）
- `learning-pipeline`：把符合条件的 chat history 转成 reviewed learning candidates（已审核学习候选）

## AI Technology Stack（AI 技术栈）
- `Microsoft.Extensions.AI` 作为 application-facing abstraction（面向应用的抽象层）
- provider-specific SDKs（供应商专属 SDK）保留在 model gateway（模型网关）后面
- `Polly` 或等价 resilience policies（弹性策略）包裹 model 与 tool 调用
- `OpenTelemetry` 记录 model、tool、policy spans（链路跨度）

## Interaction Modes（交互模式）
- `SuggestOnly`
- `Copilot`
- `Autopilot`
- `EscalationOnly`

## Decision Order（决策顺序）
1. 解析 trusted `tenant_id`、channel 和 conversation context。
2. 加载已发布的 AI policy version（AI 策略版本）。
3. 检测 intent（意图）和 risk level（风险等级）。
4. 当需要 business facts（业务事实）时，优先使用 structured facts（结构化事实）或 approved tools（已批准工具）。
5. 只有在 answer synthesis（答案生成）或 explanation（解释）需要时才使用 RAG。
6. 如果 policy 和 channel 允许，再选择 fixed asset（固定素材）或 link card（链接卡片）。
7. 对整个 decision（决策）和 fallback reason（回退原因）写入审计。

## Multimodal Rules（多模态规则）
- AI 支持的 inbound understanding（入站理解）：
  - `text`
  - `image`
- AI 在 V1 不支持的 inbound understanding：
  - `video`
- AI 支持的 outbound responses（外发响应）：
  - `text`
  - `fixed image`
  - `fixed video`
  - `predefined link card`
- 明确禁止的 outbound behavior（外发行为）：
  - `generated image`
  - `generated video`
  - `unreviewed asset selection`

## Policy Configuration（策略配置）
- 数据库存储、带版本的 configuration（配置）是 authoritative（权威来源）。
- 最少需要的 configuration groups（配置组）包括：
  - `PromptProfile`
  - `ReplyPolicy`
  - `ToolPolicy`
  - `AssetSelectionPolicy`
  - `TenantAiSettings`
  - `KnowledgeReleasePolicy`
- lifecycle（生命周期）包括：
  - `Draft`
  - `Review`
  - `Published`
  - `RolledBack`

## Tool Execution Rules（工具执行规则）
- `ReadOnly`：当 policy 允许时，可以自动执行
- `LowRiskMutating`：必须同时满足 tenant allowlist（租户白名单）、validated parameters（已校验参数）、precondition check（前置条件检查）、confidence threshold（置信度阈值）和 idempotency key
- `HighRiskMutating`：绝不自动执行；AI 只能提出建议，并转人工确认

## Audit Requirements（审计要求）
- 每次 AI decision（决策）至少必须记录：
  - `tenant_id`
  - `conversation_id`
  - `mode`
  - `policy_version`
  - `prompt_version`
  - `model_name`
  - `confidence`
  - `tool_calls`
  - `asset_choice`
  - `fallback_reason`
- 敏感图片内容不能以 raw narrative logs（原始叙述日志）形式持久化，只保留审计所需的最小摘要。

## Failure Handling（失败处理）
- model timeout（模型超时）：
  - 降级到 human handoff（转人工）或 text-only fallback（纯文本回退）
- retrieval failure（检索失败）：
  - 返回 no-answer（无答案）或 human escalation（人工升级），绝不能 hallucinate（臆造）业务事实
- tool failure（工具失败）：
  - 返回 explicit failure reason（显式失败原因），不允许 silent retry loop（静默重试循环）重复副作用
- policy load failure（策略加载失败）：
  - fail closed（拒绝）

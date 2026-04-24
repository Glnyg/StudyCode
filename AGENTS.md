# Repository AGENTS

## Product Context（产品背景）
- 这个仓库用于构建一个多租户（multi-tenant）的便携 WiFi 客服系统。
- 产品同时包含 AI 工作流（AI workflows）和人工客服工作流（human support workflows）。
- 整个系统必须保持对单人开发者（solo builder）和 coding agents 足够安全、可控、可审计。

## Design Authority（设计权威）
- 正式设计权威顺序固定为：`docs/` > `Obsidian/` > 聊天记忆（chat memory）。
- `docs/` 保存面向实现的正式规则；`Obsidian/` 是同一套结论的学习镜像（learning mirror）。当仓库文档与聊天上下文冲突时，以仓库文档为准。
- 在相关设计文档和 ADR 更新完成之前，不要 scaffold（搭脚手架）或变更 services、shared contracts、AI policies、search models、data ownership rules。
- 任何涉及 public APIs、event contracts、service boundaries、AI policy/config shape、search index model、retention strategy 的变更，都必须在同一轮改动中同步更新 `docs/`、对应 `Obsidian/` note 和相关 ADR。
- `Obsidian/` 笔记要默认读者是 beginner（初学者）。重要 technical terms 第一次高信号出现时，要尽量补上 Obsidian wikilinks（双链）指向 glossary note。
- 编辑 `Obsidian/` 时，要为以下位置添加或更新高价值 wikilinks：
  - overview bullets
  - service / object lists
  - event catalogs
  - section summaries
  - navigation / index notes
- 如果某个 formal term（正式术语）会反复出现，但还没有稳定的 wikilink target（双链目标），就在同一轮改动里补上对应 glossary/topic note。
- 不要在以下位置强行插入 wikilinks：
  - code blocks
  - JSON
  - Mermaid labels
  - file paths
  - negative / hypothetical examples
- 核心 Obsidian notes 应该解释清楚：
  - 它是什么
  - 为什么重要
  - 本项目怎么用
  - 生产/工作里怎么落地
  - 面试里怎么表达
  - 下一步该学什么

## Language And Reader Accessibility（语言与读者友好性）
- 默认说明性内容使用中文，尤其是：
  - AGENTS / checklist / review guidance
  - `docs/` 下的人类可读正式文档
  - 对应的 `Obsidian/` 教学镜像
- 你平时会接触到的大多数常用英文术语（English terms）保留英文，并尽量写成 `English（中文）`，帮助你逐步熟悉英文表达。
- 生僻、抽象、低频或容易误解的英文术语，必须在旁边补中文，不要让读者靠猜。
- 正式标识（formal identifiers）保持英文，不做中文化重命名：
  - service names
  - event names
  - shared type names
  - header names
  - `OpenAPI` paths / `operationId`
  - `JSON Schema` properties
  - ADR 编号与 slug
  - 文件名
- 如果某处英文是正式 contract 字段名或稳定标识，处理方式是旁边补中文解释，不是改字段名。
- 后续 agent 给你的说明、写入仓库的人类可读文档、补 Obsidian 镜像时，都要遵守这条语言规则。

## Git Safety（Git 安全）
- 在 substantial edits（较大改动）之前，先确认 branch 状态；如果 worktree 处于 detached HEAD，就先创建具名分支。
- 合并要通过 primary worktree（主工作树）完成。
- 永远不要提交本地工具状态，例如 `.codex/`、`.idea/`、`.vs/`。

## Default Working Loop（默认工作循环）
1. 先理解 request、constraints、affected areas。
2. 任务如果是 multi-step（多步骤）、cross-file（跨文件）或 architecture-sensitive（架构敏感），先做 plan。
3. 改 code 或 contracts 前，先检查相关 `docs/` 设计文档和 ADR。
4. 新增内容前，先搜索现有模式（existing patterns）。
5. 实现最小但完整（smallest complete）的改动，解决真实问题，不做无关扩张。
6. 能补最小有价值 regression test（回归测试）时就补。
7. 跑最小相关 checks（校验）。
8. 结束前用 `docs/code_review.md` 做自查。
9. 如果同类错误出现第二次，就在 `docs/lessons.md` 记一条短 lesson，并把一个 durable rule（耐久规则）提升进本文件或最近的子目录 `AGENTS.md`。

## Done Means（完成标准）
- 请求要 end to end（端到端）完成，而不是部分完成。
- 相关 tests、lint、typecheck、build checks 要么已经运行，要么明确说明为什么没跑。
- 行为变化需要在 tests、docs 或 examples 里反映出来。
- 不能为 tenant、auth、routing、billing-sensitive logic 引入 silent fallback（静默兜底）。
- 最终总结必须使用：`Cause / Changes / Prevention / Verification`。

## Task Shaping（任务描述方式）
- 写 request 时尽量像 GitHub issue（议题）一样清晰。
- 要包含：
  - goal
  - scope
  - non-goals
  - affected paths
  - constraints
  - acceptance checks
- 如果 API contracts 改动，要给 example requests / responses。
- 如果是照着现有模式改，要指出精确的 module / file 作为参考。
- 如果设计或架构变更引入了新术语，要在同一轮改动里补对应的 Obsidian glossary note。

## Architecture Guardrails（架构护栏）
- Runtime baseline（运行时基线）默认是 `.NET 10 LTS`，除非 ADR 明确允许例外。
- PostgreSQL 是 transactions、audit、AI configuration、knowledge metadata 的 source of truth（事实源）。
- OpenSearch 只用于 chat-history search 的 read-side（读侧），不能当 transactional truth、replay truth 或 AI knowledge truth。
- `search-service` 只从 events 构建 derived search projections（派生搜索投影），不能改写 transactional state（事务真相）。
- `ai-service` 必须保持在 explicit policy、explicit tool execution、explicit audit 之后，不要把 model-specific SDK calls 直接塞进无关服务。
- 单个 service 或单个 worker-node 掉电，都不能丢失已经 acknowledged（已确认）的 chat messages。相关 recovery semantics、replay、idempotency rules 必须先写进设计文档，再改实现。
- Inbound message 的 success 只能在 source-of-truth transaction commit 成功之后才允许 acknowledged。Outbound side effects 必须有 idempotency keys 或等价 dedupe 语义。
- 不要强行让所有服务都套同一种 architectural style（架构风格）。只有在 domain invariants（领域不变量）确实需要时才用 DDD / rich domain model；adapter、projection、orchestration-heavy 模块优先 workflow/application service。
- 仓库级默认实现风格是 `Pragmatic DDD / Workflow-first`：
  - 核心 domain 用 rich models
  - read side 用 CQRS projections
  - orchestration-heavy services 保持显式、简单

## Multi-Tenant Invariants（多租户不变量）
- 当有 trusted resolver（可信解析器）可用时，绝不能从 nullable 或 spoofable（可伪造）的客户端输入推断 tenant。
- 不能出现任何 cross-tenant reads、writes、cache hits、events、metrics、background job side effects。
- 优先传显式的 tenant context objects，而不是松散的 `tenant_id` 字符串。
- 缺少 tenant context 必须 fail closed（拒绝）且 fail loudly（明确报错）。
- 不允许引入 production `default tenant` 行为。
- admin 或 global operations 必须显式建模并单独保护。

## Support Domain Invariants（客服域不变量）
- AI 和人工工作流都必须保留 conversation history 和 audit history。
- Handoff state（交接状态）必须显式、可追踪、可恢复。
- Webhooks、message ingestion、retryable jobs 必须 idempotent（幂等）。
- Device、SIM、order、refund、after-sales 工作流必须保持 traceability（可追溯性）。
- 不要以 plaintext（明文）记录 secrets、tokens 或 customer PII。
- Realtime chat 是 hot path（热路径）。AI、search indexing、analytics、QA 可以消费 events，但不能阻塞 chat delivery。
- 用户视频消息（video messages）在 V1 必须保留 metadata 并路由给人工，不允许进入 AI hot path。
- AI 在 V1 只能发送：
  - text
  - reviewed fixed images
  - reviewed fixed videos
  - predefined link cards

## Reliability Rules（可靠性规则）
- 优先显式错误（explicit errors），不要用宽泛 catch-all recovery 掩盖问题。
- 优先 deterministic behavior（确定性行为），不要依赖隐藏 heuristics（启发式猜测）。
- 除非仓库里已有稳定模式，否则不要加 speculative abstractions（猜想式抽象）。
- 新增 helper 前，先复用已有 helper。
- Workbench search 不允许从 OpenSearch silent fallback 到宽泛 PostgreSQL 文本扫描。
- Derived stores 必须能从 source of truth 和 events 重建。
- Redis 可以保存临时 presence 或 cache，但不能成为 business truth 的唯一副本。
- 可重启 consumer 必须 idempotent 且 replay-safe。
- 掉电后的 recovery behavior 要明确写清：
  - 什么 survives（保留）
  - 什么 replays（重放）
  - 什么 reconnects（重连）
  - 什么 may lag（允许滞后）
- 只有读写模型确实显著不同，才引入 CQRS；不要为了 trivial CRUD（简单增删改查）拆一堆 handlers 和 models。

## Testing Expectations（测试期望）
- Bug fix：能补 regression test 就补。
- 新 routing 或 policy logic：必须有 positive / negative tests。
- Schema 或 contract change：更新 contract tests、docs 或 examples。
- Multi-tenant logic：覆盖 missing tenant、wrong tenant、cross-tenant attempts。
- Retryable flows：覆盖 duplicate delivery 或 replay。
- Search changes：覆盖 highlight、filtering、pagination、degraded-search behavior、replay/rebuild correctness、cross-tenant isolation。
- AI changes：覆盖 policy publish / rollback、tool gating、multimodal fallback、explicit human handoff。
- Core domain invariants 优先用 domain-level tests；workflow/orchestration 模块重点是 application-service、integration、contract tests。
- “Tests have guarantees” 的意思是：changed area 必须有正确层级的测试，不是随便跑个 smoke test 就算完。
- 对 source-of-truth services 来说，改了 invariants（不变量）就必须至少同时有：
  - domain tests
  - 一个没有该改动就会失败的 application / integration 路径

## Review（评审）
- 完成前必须检查 `docs/code_review.md`。

## Lessons（经验沉淀）
- `docs/lessons.md` 只记录 short、high-signal 的条目。
- 只有以下情况才写 lesson：
  - 同类错误第二次出现
  - bug 逃过了本地验证
  - review 抓到了 recurring issue（重复问题）
  - 发现了新的 invariant（不变量）
- 每条 lesson 控制在 8 行以内。
- 如果某条 lesson 已经变成 durable rule，就把规则提升进 `AGENTS.md`，同时把 lesson 保持简短。

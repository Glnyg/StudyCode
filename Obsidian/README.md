# Obsidian 学习入口

## 这是什么
- 这是 `docs/` 的教学镜像，用来帮助你按学习顺序理解系统、复习概念，并把设计讲清楚。
- 权威顺序始终是：`docs/` > `Obsidian/` > chat。
- 如果 `Obsidian/` 和正式设计冲突，以 `docs/` 为准。

## 先从这里开始
1. [[00-Overview/权威设计包索引|权威设计包索引]]
2. [[00-Overview/如何学习这个项目|如何学习这个项目]]
3. [[00-Overview/术语总索引|术语总索引]]

## 目录导航
- [[00-Overview/README|00-Overview]]：学习路线、工作流、设计冻结、表达方式。
- [[01-Architecture/README|01-Architecture]]：系统总览、服务边界、实现风格。
- [[02-Domain/README|02-Domain]]：[[多租户]]、客服域模型、告警旁路。
- [[03-AI/README|03-AI]]：[[Copilot]]、[[Autopilot]]、[[RAG]]、策略与工具边界。
- [[04-Data/README|04-Data]]：事务真相、派生读侧、保留与归档。
- [[05-API/README|05-API]]：公共接口、事件契约与共享字段。
- [[06-Search/README|06-Search]]：聊天记录搜索与 [[OpenSearch]] 读侧。
- [[07-Platform/README|07-Platform]]：[[Kubernetes]] 平台基线与集群分层。
- [[08-Reliability/README|08-Reliability]]：[[恢复语义]]、重放、幂等与断电恢复。
- [[09-Testing/README|09-Testing]]：验证基线与质量闸门。
- [[90-Glossary/README|90-Glossary]]：术语补课入口。
- [[ADR/README|ADR]]：冻结决策与变更边界。

## 核心主题入口
- 系统主链路：[[01-Architecture/系统总览学习笔记]]
- 多租户底线：[[02-Domain/多租户与客服域模型]]
- 搜索读侧：[[06-Search/聊天记录搜索]]
- AI 决策层：[[03-AI/AI 服务设计]]
- 断电恢复：[[08-Reliability/断电恢复与自动恢复]]
- 测试要求：[[09-Testing/测试策略与质量闸门]]
- 工作与面试表达：[[00-Overview/工作与面试表达手册]]

## 对应正式文档
- `docs/README.md`
- `docs/architecture/system-overview.md`
- `docs/domain/multi-tenant-and-domain-model.md`
- `docs/search/chat-history-search.md`
- `docs/ai/ai-service-design.md`
- `docs/reliability/power-loss-and-recovery.md`
- `docs/testing/test-strategy-and-quality-gates.md`

## 怎么使用这套资料
- 先看目录 README，再读专题笔记。
- 遇到陌生词，先回 [[00-Overview/术语总索引]] 或 [[90-Glossary/README]]。
- 想快速建立大图时，先看 [[01-Architecture/系统总览学习笔记]] 里的 Mermaid 图，再进入各专题笔记。

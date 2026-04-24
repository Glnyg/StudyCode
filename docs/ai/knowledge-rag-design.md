# Knowledge And RAG Design（知识库与 RAG 设计）

## Goal（目标）
在客服流程里提供 grounded answers（有依据的回答），同时让 knowledge publication（知识发布）、retrieval（检索）和 rollback（回滚）保持 deterministic（确定性）且 auditable（可审计）。

## Knowledge Sources（知识来源）
- Reviewed FAQ（已审核 FAQ）
- SOP 与 troubleshooting documents（排障文档）
- product and package documentation（产品与套餐文档）
- approved operational playbooks（已批准操作手册）
- 经审核后的 chat-derived learning candidates（聊天沉淀学习候选）

## V1 Non-Goals（V1 非目标）
- 不允许直接发布 raw chat transcript（原始聊天记录）
- 不做 autonomous self-training（自主自训练）
- 不让 OpenSearch 持有 vector truth（向量事实源）

## Data Flow（数据流）
1. 导入文件或 structured FAQ（结构化 FAQ）。
2. 把原始内容存入 object storage（对象存储）。
3. 解析并归一化内容。
4. 对内容切块（chunk）。
5. 生成 embeddings（向量）。
6. 把 chunk 和 embedding metadata（向量元数据）写入 PostgreSQL。
7. 审核 staged content（暂存内容）。
8. 发布 knowledge release（知识发布版本）。
9. `ai-service` 只从已发布 release 中检索。

## Core Entities（核心实体）
- `KnowledgeBase`
- `KnowledgeDocument`
- `KnowledgeDocumentVersion`
- `KnowledgeChunk`
- `KnowledgeChunkEmbedding`
- `KnowledgeRelease`
- `KnowledgeReleaseItem`
- `KnowledgeFeedback`
- `LearningCandidate`

## Storage Decisions（存储决策）
- PostgreSQL 是 metadata、versions、releases 和 embeddings 的 source of truth。
- `pgvector` 用于保存 embeddings。
- object storage 用于保存原始源文件和大体积 parsed artifacts（解析产物）。
- retrieval 顺序固定为：先 metadata filters（元数据过滤），再 vector search（向量检索），最后 rerank（重排）。

## Release Model（发布模型）
- 只有 `Published` releases 对 runtime retrieval（运行时检索）可见。
- 新导入内容会停留在 staged area（暂存区），直到审核完成。
- rollback 通过切换 active release pointer（当前发布指针）实现，而不是原地修改内容。

## Retrieval Rules（检索规则）
- 每次检索都必须带 mandatory tenant filter（强制租户过滤）。
- 可选 filters（过滤条件）包括：
  - channel
  - product line
  - scenario tag
  - effective date
- retrieval 返回 evidence chunks（证据片段）和 release version metadata 给 `ai-service`。

## Learning Pipeline（学习流水线）
- chat transcripts（聊天记录）只有在以下步骤完成后才能生成 candidates（候选）：
  - masking sensitive data（脱敏）
  - extracting candidate Q&A（抽取候选问答）
  - de-duplicating（去重）
  - human review（人工审核）
  - offline evaluation（离线评估）
- 已发布知识必须始终引用一个 reviewed release（已审核发布版本）。

## Metrics（指标）
- hit rate（命中率）
- citation coverage（引用覆盖率）
- answer adoption rate（答案采纳率）
- no-answer rate（无答案率）
- false-answer rate（错误答案率）
- stale-document recall（过期文档召回）
- tool-needed vs knowledge-needed routing quality（该走工具还是该走知识检索的分流质量）

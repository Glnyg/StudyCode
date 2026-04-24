# 03-AI 阅读导航

## 这部分讲什么
- 这里讲 `ai-service` 为什么必须独立、怎么受策略控制、什么时候查知识库、什么时候调工具、什么时候转人工。

## 为什么重要
- 这个项目里的 AI 不是自由发挥的聊天机器人，而是受 [[策略引擎]]、[[审计]]、工具边界和租户规则约束的决策层。
- 如果不把这一层讲清，后面最容易出现越权、幻觉和无法审计的问题。

## 建议先读
1. [[AI 服务设计]]
2. [[知识库与 RAG]]

## 对应正式文档
- `docs/ai/ai-service-design.md`
- `docs/ai/knowledge-rag-design.md`
- `docs/adr/0004-standardize-ai-abstractions-and-policy-model.md`

## 读完去哪里
- 想回头看系统边界：[[01-Architecture/README|01-Architecture]]
- 想看业务真相和搜索读侧：[[06-Search/README|06-Search]]
- 想看验证要求：[[09-Testing/README|09-Testing]]
- 想补 AI 术语：[[90-Glossary/README|90-Glossary]]

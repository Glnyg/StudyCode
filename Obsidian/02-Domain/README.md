# 02-Domain 阅读导航

## 这部分讲什么
- 这里讲 [[多租户]] 底线、客服域里的核心对象，以及两类管理告警旁路。

## 为什么重要
- 你做的不是普通后台，而是真实的多企业租户客服系统。
- 这一层决定哪些对象是业务真相，哪些能力必须幂等、可追踪、可回放，哪些能力只能做读侧。

## 建议先读
1. [[多租户与客服域模型]]
2. [[高风险关键词告警与紧急介入]]
3. [[客服未回复超时告警]]

## 对应正式文档
- `docs/domain/multi-tenant-and-domain-model.md`
- `docs/domain/urgent-intervention-and-management-alerting.md`
- `docs/domain/response-timeout-alerting.md`

## 读完去哪里
- 想回到系统总览：[[01-Architecture/README|01-Architecture]]
- 想继续看搜索读侧：[[06-Search/README|06-Search]]
- 想继续看 AI 决策：[[03-AI/README|03-AI]]
- 想看验证要求：[[09-Testing/README|09-Testing]]
- 想补术语：[[90-Glossary/README|90-Glossary]]

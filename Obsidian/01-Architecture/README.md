# 01-Architecture 阅读导航

## 这部分讲什么
- 这里讲系统为什么这样拆、各服务各管什么，以及代码实现风格怎么落地。

## 为什么重要
- 这部分决定你之后写代码时，知道应该把逻辑放在哪个服务、哪个读写模型、哪个旁路里。
- 如果这一层没搞清，后面很容易把真相、搜索、AI、实时推送混在一起。

## 建议先读
1. [[系统总览学习笔记]]
2. [[服务边界与运行时拓扑]]
3. [[实现风格：Pragmatic DDD 与 Workflow-first]]

## 对应正式文档
- `docs/architecture/system-overview.md`
- `docs/architecture/service-boundaries-and-runtime-topology.md`
- `docs/architecture/implementation-style-pragmatic-ddd-workflow-first.md`

## 读完去哪里
- 想看数据职责：[[04-Data/README|04-Data]]
- 想看契约边界：[[05-API/README|05-API]]
- 想继续看业务规则：[[02-Domain/README|02-Domain]]
- 想进入 AI 旁路：[[03-AI/README|03-AI]]

# 04-K8s 阅读导航

## 这部分讲什么
- 这里讲生产环境平台底座和故障恢复语义，重点是系统跑在哪里、怎么隔离、挂了以后怎么自动恢复。

## 为什么重要
- `Kubernetes` 能把 Pod 拉起来，但不能自动替你保证消息不丢、顺序不乱、重复不出。
- 所以你必须把平台基线和业务恢复语义一起理解，而不是只会画一个“集群”框。

## 建议先读
1. [[K8s 平台基线]]
2. [[断电恢复与自动恢复]]

## 对应正式文档
- `docs/platform/k8s-baseline.md`
- `docs/reliability/power-loss-and-recovery.md`
- `docs/adr/0006-single-node-failure-recovery-semantics.md`

## 读完去哪里
- 想回头看服务拓扑：[[01-Architecture/README|01-Architecture]]
- 想补恢复相关术语：[[90-Glossary/README|90-Glossary]]
- 想把平台设计讲给别人：[[00-Overview/工作与面试表达手册|工作与面试表达手册]]

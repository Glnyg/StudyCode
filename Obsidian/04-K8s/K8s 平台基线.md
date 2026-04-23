# K8s 平台基线

对应正式文档：`docs/platform/k8s-baseline.md`

## 这是什么
- 这是整个系统上线到生产环境时的运行底座。
- 你可以把它理解成：业务代码最终跑起来的“操作系统级平台”。

## 生产底座
- [[RKE2]]
- ingress-nginx
- cert-manager
- [[Argo CD]]
- [[Helm]]
- Prometheus/Grafana
- Loki
- Tempo
- [[OpenTelemetry]]

## 关键隔离
- gateway、core、ai、stateful 分池
- 状态型组件不要和普通业务 Pod 混布

## 为什么这样做
- 因为这个系统有两类东西：
  - 吃 CPU 和网络的实时/AI 服务
  - 吃磁盘和内存的状态型组件
- 如果混在一起，性能和故障面都会变差。

## 在本项目里怎么用
- [[SignalR]] 网关在 gateway 池
- 业务服务在 core 池
- AI worker 在 ai 池
- [[PostgreSQL]]、[[OpenSearch]]、[[RabbitMQ]]、[[Redis]] 在 stateful 池

## 工作里怎么用
- 你以后设计部署方案时，不要只画一个“[[Kubernetes]] 集群”就结束。
- 要继续往下问：
  - 节点怎么分池
  - 状态型和无状态怎么隔离
  - 观测怎么做
  - 回滚怎么做

## 面试怎么说
- “我会把 Kubernetes 平台基线和业务架构一起设计，特别是状态型组件隔离、GitOps、观测和实时网关的部署方式。”

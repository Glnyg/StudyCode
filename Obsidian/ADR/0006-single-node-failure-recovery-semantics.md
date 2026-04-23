# ADR-0006 学习摘要

正式文档：`docs/adr/0006-single-node-failure-recovery-semantics.md`

- 单服务或单节点故障后，已确认的消息不能丢。
- K8s 负责拉起服务，不负责业务真相。
- 关键依赖是 PostgreSQL 真源、Outbox、RabbitMQ 持久化、幂等消费和客户端 replay。

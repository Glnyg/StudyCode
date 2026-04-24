# 08-Reliability 阅读导航

## 这部分讲什么
- 这里讲已确认消息不丢、断电恢复、重放、幂等和自动恢复边界。

## 为什么重要
- 这个项目最怕的是“看起来服务重启了，但业务事实已经丢了”。
- 只有把提交、投递、补拉和重放语义讲清，单点故障才不会演变成真实事故。

## 建议先读
1. [[断电恢复与自动恢复]]

## 对应正式文档
- `docs/reliability/power-loss-and-recovery.md`
- `docs/adr/0006-single-node-failure-recovery-semantics.md`

## 读完去哪里
- 想看平台底座：[[07-Platform/README|07-Platform]]
- 想看搜索重建：[[06-Search/README|06-Search]]
- 想看验收清单：[[09-Testing/README|09-Testing]]

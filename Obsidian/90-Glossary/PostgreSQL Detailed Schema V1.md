# PostgreSQL Detailed Schema V1

## 它是什么
- 这是把“[[PostgreSQL]] 是事实源”进一步落成可编码的数据模型冻结包。
- 它回答的不是“用不用 PostgreSQL”，而是“每张表到底怎么设计、怎么支持重放、幂等和审计”。

## 为什么重要
- 没有这份冻结包，服务实现时就会边写 migration（迁移）边猜字段。
- 对 [[conversation-service]]、[[routing-service]] 这种 source-of-truth service（事实源服务）来说，这会直接破坏 [[幂等]]、重放和审计语义。

## 本项目怎么用
- 它应该冻结：
  - logical schema（逻辑表结构）
  - 主键 / 唯一键 / 索引
  - `message_id` 与 `sequence`
  - `outbox/inbox`
  - audit columns（审计字段）
  - retention / archive hooks（保留与归档钩子）

## 工作里怎么落地
- 你在开工前要先确认：表结构是不是已经足够支持重试、重复投递、replay 和数据归档。
- 如果这些规则还只存在聊天记忆里，而没写成 schema freeze（模式冻结），就不算真的 ready。

## 面试里怎么表达
- “我会把数据库设计当成实现冻结件，而不是把它推迟到编码时再补。尤其是幂等键、顺序规则、审计字段和 outbox/inbox，必须在 migration 前写死。” 

## 你下一步应该看什么
1. [[PostgreSQL]]
2. [[Outbox 模式]]
3. [[断电恢复与自动恢复]]
4. [[开工前设计冻结清单]]

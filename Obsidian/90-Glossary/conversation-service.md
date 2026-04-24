# conversation-service

## 是什么
- 负责消息、会话状态、[[审计]] 和评估的事务真源服务。

## 在本项目里怎么用
- 入站消息先由 [[conversation-service]] 写入 [[PostgreSQL]]。
- 提交成功后再通过 [[Outbox 模式]] 发布 [[MessageAppended]] 等已提交事件。
- [[routing-service]]、[[search-service]]、[[ai-service]] 都以它提供的会话事实为准。

## 生产里要注意
- 已确认接收的消息只能在事务提交后返回成功。
- 它不拥有队列策略、AI 策略或搜索索引。
- 对外发布的事件必须可重放、可审计、可 [[幂等]] 消费。

## 面试怎么说
- “conversation-service 是聊天真相服务，先负责把消息和会话状态写稳，再把变化通过事件发给路由、搜索和 AI 这些旁路能力。”

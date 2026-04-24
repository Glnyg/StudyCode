# CQRS

## 是什么
- Command Query Responsibility Segregation。
- 简单说，就是把“写入”和“读取”按职责拆开。

## 在本项目里怎么用
- [[conversation-service]] 写真相。
- [[search-service]] 和 [[analytics-service]] 做读模型。

## 生产里要注意
- 读写分离有价值时再用。
- 不要为了模式而把简单 CRUD 拆得很复杂。

## 面试怎么说
- “CQRS 适合读写差异大的系统，比如事务真源和搜索/报表读侧明显分离的场景。”

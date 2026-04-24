# 04-Data 阅读导航

## 这部分讲什么
- 这里讲数据该放在哪、什么是真相、什么是派生读侧，以及保留与归档边界怎么划。

## 为什么重要
- 这个项目同时用了 [[PostgreSQL]]、[[OpenSearch]]、[[Redis]]、[[RabbitMQ]] 和 [[对象存储]]。
- 如果不先把数据职责分清，后面就会把事务真相、搜索投影、缓存状态和文件资产混在一起。

## 建议先读
1. [[数据职责与保留策略]]

## 对应正式文档
- `docs/data/storage-and-retention.md`
- `docs/adr/0002-data-ownership-and-derived-stores.md`

## 读完去哪里
- 想看搜索读侧：[[06-Search/README|06-Search]]
- 想看 [[恢复语义]]：[[08-Reliability/README|08-Reliability]]
- 想补数据术语：[[90-Glossary/README|90-Glossary]]

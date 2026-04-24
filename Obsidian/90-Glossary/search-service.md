# search-service

## 是什么
- 负责聊天记录搜索读侧、搜索 API、自动补全和索引重建的搜索服务。

## 在本项目里怎么用
- 它消费 [[conversation-service]] 发出的 [[MessageAppended]] 等事件，在 [[OpenSearch]] 里维护搜索读模型。
- 客服工作台通过它做关键词、高亮、筛选和分页查询。
- 找到命中结果后，完整会话仍然回源到 [[conversation-service]] 获取。

## 生产里要注意
- 它只拥有搜索投影，不拥有事务真相。
- 不能在 [[OpenSearch]] 不可用时偷偷回退到广义 [[PostgreSQL]] 全库文本扫描。
- 索引必须能从真源事件重建。

## 面试怎么说
- “search-service 只负责把消息真相投影成搜索体验，不回写业务状态，这样搜索能力和事务真相边界就不会混掉。”

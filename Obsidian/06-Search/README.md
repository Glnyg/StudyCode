# 06-Search 阅读导航

## 这部分讲什么
- 这里讲客服工作台的聊天记录搜索、[[OpenSearch]] 读侧、索引构建和降级边界。

## 为什么重要
- 搜索体验很容易被误实现成“直接扫事务库”，但这个项目明确要求搜索和事务真相分离。
- 只有把搜索读侧讲清，才能同时保住工作台体验和主链路稳定。

## 建议先读
1. [[聊天记录搜索]]

## 对应正式文档
- `docs/search/chat-history-search.md`
- `docs/adr/0003-chat-search-uses-opensearch-read-side.md`

## 读完去哪里
- 想看数据职责：[[04-Data/README|04-Data]]
- 想看恢复与重建：[[08-Reliability/README|08-Reliability]]
- 想看验证要求：[[09-Testing/README|09-Testing]]

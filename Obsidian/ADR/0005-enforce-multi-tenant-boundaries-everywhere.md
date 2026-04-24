# ADR-0005 学习摘要

正式文档：`docs/adr/0005-enforce-multi-tenant-boundaries-everywhere.md`

- 租户边界不只在数据库
- 搜索、AI、缓存、[[对象存储]]、事件都必须带 `tenant_id`
- 缺失租户就失败

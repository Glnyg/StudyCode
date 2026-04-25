# Implementation Freeze Issues（实现冻结议题）

## Goal（目标）
把 [implementation-freeze-checklist.md](../implementation-freeze-checklist.md) 里的待冻结事项拆成可单独跟踪、可单独指派、可单独验收的 issue-like documents（议题文档）。

## How To Use（怎么使用）
- 每个文件都可以直接复制成 GitHub issue，或作为内部设计任务单使用。
- `P0` 表示阻塞大范围编码或对应服务实现启动的冻结项。
- `P1` 表示可以在第一轮骨架后推进，但必须在对应里程碑前关闭的冻结项。
- 如果某个冻结项被拆成更细的子任务，子任务也必须保持和这里相同的权威文档引用关系。

## P0 Issues（编码前优先关闭）
1. [P0-01 PostgreSQL Detailed Schema V1](./p0-01-postgresql-detailed-schema-v1.md)
2. [P0-02 Engineering Baseline V1](./p0-02-engineering-baseline-v1.md)
3. [P0-03 Upstream Integration Specs V1](./p0-03-upstream-integration-specs-v1.md)

## P1 Issues（按里程碑推进）
1. [P1-01 Search Freeze Package](./p1-01-search-freeze-package.md)
2. [P1-02 AI Freeze Package](./p1-02-ai-freeze-package.md)
3. [P1-03 Media And Asset Freeze Package](./p1-03-media-and-asset-freeze-package.md)
4. [P1-04 Observability And SRE Freeze Package](./p1-04-observability-and-sre-freeze-package.md)
5. [P1-05 Intervention And Notification Freeze Package](./p1-05-intervention-and-notification-freeze-package.md)

## Source Of Truth（权威来源）
- 总体冻结状态与交付顺序：
  - [implementation-readiness-and-design-freeze.md](../implementation-readiness-and-design-freeze.md)
- 执行型总清单：
  - [implementation-freeze-checklist.md](../implementation-freeze-checklist.md)

## Governance Rule（治理规则）
- 这些 issue 解决的是 implementation freeze（实现冻结），不是重新设计大架构。
- 如果只是在补字段、补约束、补恢复语义、补工程规约，就更新对应 issue 和权威文档。
- 只有 runtime baseline、data ownership、multi-tenant boundary、AI safety boundary 发生变化时，才需要更新 ADR。

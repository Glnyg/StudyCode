# ADR 0001：采用 .NET 10 LTS 作为运行时基线

## Status（状态）
Accepted（已接受）

## Context（背景）
这个系统从 2026 年开始建设，目标是长期生产使用。`.NET 8` 的支持会在 2026-11-10 结束，对于一个 greenfield（全新）平台基线来说时间太近。

## Decision（决策）
采用 `.NET 10 LTS` 作为所有新服务的默认 runtime、SDK 和 ASP.NET Core 基线。

## Consequences（影响）
- 新服务默认目标框架是 `.NET 10`。
- runtime guidance、CI、container images、deployment documentation 都围绕 `.NET 10` 对齐。
- 如果要回退到 `.NET 8`，必须有显式例外说明和 migration plan（迁移计划）。

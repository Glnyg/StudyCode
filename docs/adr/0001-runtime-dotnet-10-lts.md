# ADR 0001: Adopt .NET 10 LTS As The Runtime Baseline

## Status
Accepted

## Context
This system starts in 2026 and targets long-lived production use. `.NET 8` support ends on 2026-11-10, which is too close for a greenfield platform baseline.

## Decision
Adopt `.NET 10 LTS` as the default runtime, SDK, and ASP.NET Core baseline for all new services.

## Consequences
- New services target `.NET 10`.
- Runtime guidance, CI, container images, and deployment documentation align to `.NET 10`.
- Falling back to `.NET 8` requires an explicit exception and migration plan.

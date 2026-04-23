# ADR 0004: Standardize AI Behind Abstractions And Versioned Policy

## Status
Accepted

## Context
The system needs model portability, tenant-level AI configuration, controlled tool execution, and auditable fallbacks.

## Decision
- `ai-service` uses `Microsoft.Extensions.AI` abstractions at the application boundary.
- Provider SDKs stay behind a model gateway.
- Prompt, reply, tool, asset, and tenant AI settings are versioned in PostgreSQL and published through explicit lifecycle states.

## Consequences
- Business logic is insulated from provider churn.
- AI behavior changes require configuration publication and audit.
- Unreviewed prompt or tool changes may not go live silently.

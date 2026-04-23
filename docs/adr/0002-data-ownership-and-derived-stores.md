# ADR 0002: Keep PostgreSQL As Source Of Truth And Derived Stores Rebuildable

## Status
Accepted

## Context
The system uses PostgreSQL, OpenSearch, Redis, RabbitMQ, and object storage. Without clear ownership, derived stores can silently become de facto sources of truth.

## Decision
- PostgreSQL is the transaction, audit, AI configuration, and knowledge metadata source of truth.
- OpenSearch, Redis, and analytics read models are derived and rebuildable.
- Services may not bypass ownership boundaries and write business truth into derived stores only.

## Consequences
- Search or analytics rebuild flows are mandatory.
- Incident response must prefer replay from PostgreSQL and events.
- Cross-service direct table reads are disallowed.

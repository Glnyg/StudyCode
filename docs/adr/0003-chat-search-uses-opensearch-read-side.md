# ADR 0003: Use OpenSearch For Chat History Search Read-Side

## Status
Accepted

## Context
The workbench requires fast tenant-safe search with highlight, filtering, autocomplete, and 1-year online search retention. PostgreSQL remains the transactional source of truth.

## Decision
- Introduce `search-service` backed by OpenSearch for chat history search.
- Keep PostgreSQL FTS only for low-frequency operational fallback and targeted admin usage.
- Search data is projected asynchronously from domain events.

## Consequences
- Search becomes eventually consistent.
- OpenSearch outages return explicit degraded-search errors instead of silent SQL scans.
- Search index schema and retention policy become first-class design artifacts.

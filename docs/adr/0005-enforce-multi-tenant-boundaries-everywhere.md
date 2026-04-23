# ADR 0005: Enforce Tenant Boundaries Across Runtime, Search, And AI

## Status
Accepted

## Context
This product is a real multi-tenant customer service system. Search projections, AI policies, and media assets can leak data just as easily as transactional queries if tenant boundaries are weak.

## Decision
- `tenant_id` is mandatory across requests, events, caches, search documents, object keys, and AI decisions.
- Missing tenant context fails closed.
- No production default tenant behavior is allowed.

## Consequences
- Tenant filtering is mandatory for every search query and every knowledge retrieval.
- Shared infrastructure does not imply shared data visibility.
- Cross-tenant tests are required for transactional, search, and AI flows.

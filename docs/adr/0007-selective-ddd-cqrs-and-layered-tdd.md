# ADR 0007: Use Selective DDD/CQRS And Layered TDD

## Status
Accepted

## Context
The system spans core transactional domains, integration adapters, derived read models, and AI orchestration. Forcing one implementation style everywhere would create either anemic domain logic in core services or excessive ceremony in adapter/projection services.

## Decision
- Use DDD and rich domain models in core domains with strong invariants.
- Use CQRS where read/write models diverge materially.
- Use workflow/application-service style in adapter, projection, and orchestration-heavy services.
- Use TDD across the project, but choose test layers based on service type and risk.

## Consequences
- Implementation style differs by service on purpose.
- Reviewers should reject both over-modeling and under-modeling.
- The architecture remains consistent because the selection criteria are explicit.

# Implementation Style: Pragmatic DDD / Workflow-First

## Goal
Define the official implementation style for this system so future code follows a consistent, production-safe approach without forcing one pattern across every service.

## Official Recommendation
Use:
- `Pragmatic DDD` for core source-of-truth services with real invariants
- `Workflow-first` application services for adapter, orchestration, and projection-heavy services
- `Selective CQRS` where read and write models materially differ
- `Layered TDD` so tests protect the most failure-prone layer first

This is the preferred style over “full-project uniform DDD/CQRS everywhere.”

## Why This Style Fits This System
- The system mixes:
  - hard transactional domains
  - realtime delivery
  - search projections
  - AI policy orchestration
  - upstream adapters
- These have different failure modes and different modeling needs.
- Forcing one style everywhere would either:
  - under-model core business rules, or
  - over-model simple adapters and projections into unnecessary ceremony.

## Default Internal Structure
- Preferred service-internal shape:
  - transport layer
  - application layer
  - domain layer where justified
  - infrastructure/adapters
- Prefer vertical slices for cohesive features over broad technical-layer folders when that improves locality.
- Keep domain model isolated from HTTP, MQ, OpenSearch, model SDK, and storage-specific details.

## Where Pragmatic DDD Applies

### `conversation-service`
Use `DDD + rich domain model`.

Reasons:
- strong state transitions
- message sequencing rules
- conversation mode changes
- audit-sensitive invariants
- replay and idempotency constraints

Recommended aggregates:
- `Conversation`
- `Message`
- `ConversationTimeline`
- `ConversationEvaluation`

### `routing-service`
Use `DDD + rich domain model`.

Reasons:
- queue lifecycle
- assignment rules
- transfer invariants
- inactivity offline rules
- agent state transitions

Recommended aggregates:
- `QueueTicket`
- `Assignment`
- `Transfer`
- `AgentPresence`

### `knowledge-service`
Use moderate `DDD`.

Reasons:
- review/publish/rollback invariants
- release visibility rules
- lifecycle governance

Recommended aggregates:
- `KnowledgeDocument`
- `KnowledgeRelease`
- `LearningCandidate`

### `media-service` asset governance
Use selective `DDD`.

Reasons:
- review state
- effective dates
- channel compatibility
- tenant visibility

Recommended aggregates:
- `AssetItem`
- `LinkCardTemplate`

## Where Workflow-First Wins

### `channel-service`
Preferred style:
- adapter layer
- request normalization
- signature validation
- idempotent webhook handling
- explicit application services / transaction scripts

Why:
- it is integration-heavy and acts as an anti-corruption layer

### `search-service`
Preferred style:
- projection builders
- OpenSearch mappers
- query services
- rebuild jobs

Why:
- it owns derived read models, not business-truth aggregates

### `analytics-service`
Preferred style:
- aggregators
- read-model builders
- reporting query services

Why:
- analytics is projection-oriented and derived

### `ai-service`
Preferred style:
- orchestrator
- policy objects
- workflow steps
- explicit tool executor
- audit logger

Why:
- its complexity comes from decision flow, risk control, fallback, and external calls
- not from a single aggregate root with rich internal state

### `device-service`
Preferred style:
- anti-corruption layer
- application services
- upstream adapter mapping

Why:
- it wraps upstream truth instead of owning deep internal business state

## Selective CQRS Guidance
- CQRS is mandatory where read and write models differ materially.
- This system already requires architecture-level CQRS in:
  - `conversation-service` writes vs `search-service` read model
  - transactional truth vs analytics read models
- Inside a service, use CQRS only when:
  - command and query models differ meaningfully
  - scaling needs differ
  - validation and side effects differ
- Do not introduce handler-per-endpoint or duplicate command/query types for trivial CRUD without a concrete benefit.

## Layered TDD Guidance

### Core Domain Services
Write first:
- aggregate invariant tests
- legal and illegal state transition tests
- duplicate/replay safety tests

Then:
- application service tests
- repository/integration tests

### Workflow And Integration Services
Write first:
- workflow tests
- adapter tests
- contract tests
- idempotency tests

### Search And Analytics
Prioritize:
- projection tests
- mapping tests
- query behavior tests
- rebuild/replay tests

### AI
Prioritize:
- policy decision tests
- tool gating tests
- fallback tests
- prompt/config resolution tests
- audit completeness tests

Avoid brittle model-output snapshots as the primary confidence mechanism.

## Test Assurance Rules
- A change is not “tested” merely because some test passed.
- The changed layer must have the right test type:
  - domain rule change -> domain invariant tests
  - workflow/orchestration change -> application/integration tests
  - contract change -> contract tests
  - projection/search change -> projection/query/rebuild tests
  - AI policy change -> policy/fallback/audit tests
- Every source-of-truth rule change must have at least one test that would have failed before the change.
- Every replay-sensitive path must have duplicate-delivery or retry coverage.

## Repository-Level Review Questions
- Is this service source-of-truth or derived?
- Does it protect real invariants or mostly orchestrate external systems?
- Would a rich aggregate reduce duplicated rule logic here, or only add ceremony?
- Does CQRS solve a real read/write mismatch here?
- Are tests protecting the highest-risk layer?

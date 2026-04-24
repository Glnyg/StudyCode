# Test Strategy And Quality Gates

## Goal
Define what “tests have guarantees” means in this repository.

## Principle
A passing test suite is only meaningful if the changed area is protected by the correct test layer.

## Mandatory Test Layers By Change Type

### Core Domain Change
Examples:
- conversation mode transition
- queue assignment rule
- transfer invariant
- knowledge release visibility

Required:
- domain invariant tests
- one application-service or integration path

### Workflow / Orchestration Change
Examples:
- channel webhook handling
- AI orchestration step ordering
- device command flow
- urgent intervention notification flow
- response-timeout alert scheduling and dispatch

Required:
- application-service tests
- integration or contract tests
- idempotency/retry coverage where applicable

### Search Change
Examples:
- search mapping
- query filter logic
- projection builder changes

Required:
- projection tests
- query behavior tests
- rebuild or replay coverage

### AI Policy Change
Examples:
- prompt selection
- tool policy
- asset policy
- fallback behavior

Required:
- policy decision tests
- fallback tests
- audit completeness tests

### Public Contract Change
Examples:
- HTTP API shape
- gRPC contract
- domain event schema

Required:
- contract tests
- migration or compatibility notes in docs

## Quality Gates
- No merge-ready change should rely only on manual testing when an automated test is feasible.
- “Happy path only” is not sufficient for routing, AI policy, or multi-tenant logic.
- Multi-tenant changes require:
  - missing tenant case
  - wrong tenant case
  - cross-tenant attempt case
- Replay-sensitive changes require:
  - duplicate delivery test
  - retry after partial failure test

## Minimal Acceptance For “Tested”
- At least one test would fail before the change and pass after it.
- The test exercises the layer where the defect would be most dangerous.
- The test name or scenario clearly encodes the business rule, not just the implementation detail.

## Anti-Patterns
- Adding a smoke test instead of a domain rule test
- Using only controller tests for domain invariants
- Relying only on mocked unit tests for retry, replay, or integration behavior
- Claiming coverage based on unrelated broad test suites

## Release-Critical Paths
These require especially strong coverage:
- inbound message durability
- outbox/inbox replay
- queue assignment and transfer
- urgent intervention trigger, dedupe, and notification retry
- response-timeout window creation, clear semantics, dedupe, and notification retry
- AI tool gating
- tenant isolation
- search projection rebuild
- websocket reconnect and replay

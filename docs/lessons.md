# Lessons Log

Purpose: capture only high-signal mistakes that should reduce future mistakes by Codex and by the repo workflow.

Rules:
- This is not a diary.
- One issue equals one short entry.
- Prefer concrete failure modes over abstract advice.
- If a lesson becomes a stable rule, move that rule into the nearest `AGENTS.md`.
- Prefer prevention that can be enforced by tests, review, or checks.

## Entry Template

### YYYY-MM-DD - short title
Cause:
Impact:
Guard:
Prevention:
Verification:
Promote to: `AGENTS.md` | `test` | `review checklist` | `docs`

## Seed Entries

### 2026-04-22 - tenant fallback leak
Cause: Code used a default tenant when the trusted resolver returned null.
Impact: A request could read or write the wrong tenant scope.
Guard: Missing tenant context must fail closed.
Prevention: Never add production default tenant behavior.
Verification: Add tests for missing tenant, forged tenant, and cross-tenant access.
Promote to: `AGENTS.md`, `test`

### 2026-04-22 - duplicate webhook side effects
Cause: A handler assumed at-most-once delivery from an external system.
Impact: Duplicate messages, tickets, or orders could be created.
Guard: Require idempotency keys or a dedupe window for inbound events.
Prevention: Treat every webhook and retryable job as replayable.
Verification: Add a duplicate delivery regression test.
Promote to: `AGENTS.md`, `test`

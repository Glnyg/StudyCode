# Code Review Checklist

Use this file for self-review before finishing a task.

## Correctness
- Does the change solve the root cause instead of only the symptom?
- Are success paths and failure paths both handled intentionally?
- Did the change preserve existing behavior where behavior was not meant to change?
- Are assumptions explicit in code, tests, or docs?

## Multi-Tenant Safety
- Can any request read or write another tenant's data?
- Are query filters, cache keys, events, and jobs correctly tenant-scoped?
- Does missing tenant context fail closed?
- Did the change accidentally introduce a default tenant or implicit global path?

## Contracts And Data
- If an API, event, DTO, schema, or config contract changed, were all connected surfaces updated?
- Are migrations, backfills, or compatibility concerns accounted for?
- Are examples or docs updated when they help prevent misuse?

## Reliability
- Are retries, duplicate deliveries, and re-entrancy handled where needed?
- Are errors explicit instead of silently swallowed?
- Did the change add brittle fallback logic that hides real failures?
- Is there any hidden coupling to timing, ordering, or background job behavior?

## Security And Privacy
- Is authz still correct after the change?
- Are secrets, tokens, or customer PII kept out of logs?
- Is any client-controlled input being trusted too early?

## Observability And Operations
- Will failures be diagnosable from logs, metrics, traces, or audit records?
- Is AI-to-human handoff or human-to-AI handoff traceable if the feature touches workflow logic?
- If the feature changes routing or automation, can operators understand what happened?

## Code Quality
- Did you reuse an existing pattern instead of inventing a new one?
- Is the code simpler after the change, or at least not more confusing?
- Are names, boundaries, and responsibilities clear?

## Tests
- Is there at least one test or check that would fail without this change?
- For bug fixes, is there a regression test when feasible?
- For policy or routing logic, are there both positive and negative cases?
- For multi-tenant logic, are wrong-tenant and missing-tenant cases covered?

## Lessons
- Is this the second time the same class of mistake appeared?
- If yes, did you add a short note to `docs/lessons.md`?
- If yes, did you also promote one durable rule into `AGENTS.md`?

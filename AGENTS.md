# Repository AGENTS

## Product Context
- This repository is for a multi-tenant customer service system for portable WiFi devices.
- The product combines AI workflows and human support workflows.
- The system must stay safe for a solo builder working with coding agents.

## Design Authority
- Formal design source of truth priority is: `docs/` > `Obsidian/` > chat memory.
- `docs/` contains implementation-facing rules. `Obsidian/` mirrors the same decisions for learning and recall. Do not treat chat context as authority when the repo documents disagree.
- Do not scaffold or change services, shared contracts, AI policies, search models, or data ownership rules before the relevant design docs and ADRs exist or are updated.
- Any change to public APIs, event contracts, service boundaries, AI policy/config shape, search index model, or retention strategy must update `docs/`, the matching `Obsidian/` note, and a relevant ADR in the same change.
- Obsidian notes must assume the reader is a beginner. First mentions of important technical terms should use Obsidian wikilinks to glossary notes.
- Core Obsidian notes should explain: what it is, why it matters, how this project uses it, how to apply it in production/work, how to explain it in interviews, and what to study next.

## Codex Git Workflow
- When working inside a Codex `git worktree`, check `git branch --show-current` before substantial edits.
- If the worktree is in detached `HEAD`, create a task branch first with `powershell -File scripts/codex/start-worktree-task.ps1 -TaskName "<task-name>"`.
- Default task branch pattern is `codex/<task-slug>`.
- Prefer `powershell -File scripts/codex/finish-worktree-task.ps1 -CommitMessage "<message>"` to finalize worktree changes, and add `-Merge` when the user wants the branch merged back into the primary `main` worktree.
- Merge back through the primary `main` worktree instead of trying to switch a detached Codex worktree onto `main`.
- Do not stage or commit `.codex/`, `.idea/`, `.vs/`, or other local-only tool state.

## Default Working Loop
1. Understand the request, constraints, and affected areas.
2. If the task is multi-step, cross-file, or architecture-sensitive, plan before editing.
3. Check the relevant `docs/` design file and ADR before changing code or contracts.
4. Search for existing patterns before adding new code.
5. Implement the smallest complete change that solves the real problem.
6. Add or update the smallest useful regression test when feasible.
7. Run the smallest relevant checks for the changed area.
8. Review the diff against `docs/code_review.md`.
9. If the same mistake appears twice, add a short entry to `docs/lessons.md` and fold one durable rule into this file or the nearest subdirectory `AGENTS.md`.

## Done Means
- The request is implemented end to end, not partially.
- Relevant tests, lint, typecheck, or build checks were run, or an explicit reason is given if they were not.
- Behavior changes are reflected in tests, docs, or examples where needed.
- No silent fallback was introduced for tenant, auth, routing, or billing-sensitive logic.
- Final summaries should use: `Cause / Changes / Prevention / Verification`.

## Task Shaping
- Write requests as if they were GitHub issues.
- Include goal, scope, non-goals, affected paths, constraints, and acceptance checks.
- If API contracts change, include example requests and responses.
- If copying an existing pattern, point to the exact module or file to follow.
- If a design or architecture change introduces new terminology, add or update the matching Obsidian glossary note in the same change.

## Architecture Guardrails
- Runtime baseline is `.NET 10 LTS` unless an ADR explicitly allows an exception.
- PostgreSQL is the source of truth for transactions, audit, AI configuration, and knowledge metadata.
- OpenSearch is only the chat-history search read-side. Do not use it as transactional truth, replay truth, or AI knowledge truth.
- `search-service` builds derived search projections from events. It must not mutate transactional state.
- `ai-service` must stay behind explicit policy, explicit tool execution, and explicit audit. Do not embed model-specific SDK calls directly into unrelated services.
- Single service or single worker-node power loss must not lose already-acknowledged chat messages. Recovery semantics, replay, and idempotency rules must be documented before implementation changes.
- Inbound message success may only be acknowledged after source-of-truth transaction commit. Outbound side effects must use idempotency keys or equivalent dedupe semantics.
- Do not force one architectural style across every service. Use DDD and rich domain models only where domain invariants justify them; use workflow/application services for adapter, projection, and orchestration-heavy components.
- Preferred repository-level implementation style is `Pragmatic DDD / Workflow-first`: core domains get rich models, read sides get CQRS projections, and orchestration-heavy services stay explicit and simple.

## Multi-Tenant Invariants
- Never infer tenant from nullable or spoofable client input when a trusted resolver exists.
- No cross-tenant reads, writes, cache hits, events, metrics, or background job side effects.
- Prefer explicit tenant context objects over passing loose `tenant_id` strings.
- Missing tenant context must fail closed and fail loudly.
- Do not introduce production `default tenant` behavior.
- Admin or global operations must be explicit and separately guarded.

## Support Domain Invariants
- AI and human workflows must preserve conversation history and audit history.
- Handoff state must be explicit, traceable, and recoverable.
- Webhooks, message ingestion, and retryable jobs must be idempotent.
- Device, SIM, order, refund, and after-sales workflows must preserve traceability.
- Do not log secrets, tokens, or customer PII in plaintext.
- Realtime chat is the hot path. AI, search indexing, analytics, and QA may consume events but must not block chat delivery.
- User video messages must persist metadata and route to human in V1. Do not send video into the AI hot path.
- AI may only send text, reviewed fixed images, reviewed fixed videos, or predefined link cards.

## Reliability Rules
- Favor explicit errors over broad catch-all recovery.
- Prefer deterministic behavior over hidden heuristics.
- Avoid speculative abstractions unless the pattern already exists in the codebase.
- Reuse existing helpers before creating new ones.
- Do not add silent fallbacks from OpenSearch to broad PostgreSQL text scans for workbench search.
- Derived stores must be rebuildable from source truth and events.
- Redis may hold temporary presence or cache state, but never the only copy of business truth.
- Consumers that can be restarted after faults must be idempotent and replay-safe.
- Recovery behavior after power loss must be explicit: what survives, what replays, what reconnects, and what may lag.
- CQRS is required where read and write models differ materially, but do not introduce handler or model splits for trivial CRUD without a concrete benefit.

## Testing Expectations
- Bug fix: add a regression test when feasible.
- New routing or policy logic: add positive and negative tests.
- Schema or contract change: update contract tests, docs, or examples.
- Multi-tenant logic: cover missing tenant, wrong tenant, and cross-tenant attempts.
- Retryable flows: cover duplicate delivery or replay.
- Search changes: cover highlight, filtering, pagination, degraded-search behavior, replay/rebuild correctness, and cross-tenant isolation.
- AI changes: cover policy publish/rollback, tool gating, multimodal fallback, and explicit human handoff.
- Core domain invariants should have domain-level tests first. Workflow/orchestration modules should emphasize application-service, integration, and contract tests.
- “Tests have guarantees” means merges are blocked unless the changed area has the required test layer, not just any test. A passing low-value smoke test does not satisfy this rule.
- For source-of-truth services, changed invariants require domain tests plus at least one application/integration path that would fail without the change.

## Review
- Before finishing, check `docs/code_review.md`.

## Lessons
- `docs/lessons.md` is for short, high-signal entries only.
- Write a lesson only when:
  - the same mistake appears twice
  - a bug escaped local verification
  - review found a recurring issue
  - a new invariant was discovered
- Keep each lesson under 8 lines.
- If a lesson becomes durable, move the rule into `AGENTS.md` and keep the lesson brief.

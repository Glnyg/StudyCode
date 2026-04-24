# Customer Service Authority Package

## Purpose
- This directory is the formal source of truth for the portable WiFi customer service system.
- Code generation, implementation, review, and future AI-assisted changes must follow these documents before relying on chat context.

## Precedence
1. `docs/`
2. `Obsidian/`
3. Chat memory

`AGENTS.md` contains hard process and safety guardrails. It does not replace formal design documents.

## Entry Points
- `architecture/system-overview.md`: system goals, operating model, and top-level architecture.
- `architecture/service-boundaries-and-runtime-topology.md`: service ownership, runtime lanes, and hot-path rules.
- `architecture/implementation-readiness-and-design-freeze.md`: what is already frozen, what still blocks coding, and the required delivery order.
- `architecture/implementation-style-pragmatic-ddd-workflow-first.md`: official implementation style, where DDD/CQRS apply, where workflow-first wins, and how TDD should be layered.
- `domain/multi-tenant-and-domain-model.md`: tenant model, identity, conversation lifecycle, routing, media, and asset boundaries.
- `domain/urgent-intervention-and-management-alerting.md`: high-risk keyword detection, urgent intervention, management notification, and device-enrichment rules.
- `search/chat-history-search.md`: chat history search design and OpenSearch read-side rules.
- `ai/ai-service-design.md`: AI service structure, policy model, tool execution, and multimodal handling.
- `ai/knowledge-rag-design.md`: knowledge base and RAG data flow, release, and evaluation.
- `data/storage-and-retention.md`: PostgreSQL, OpenSearch, Redis, RabbitMQ, and object storage responsibilities.
- `reliability/power-loss-and-recovery.md`: recovery semantics, no-loss guarantees, replay rules, and single-node failure behavior.
- `api/public-contracts-and-events.md`: public HTTP/gRPC contracts, event envelope, and shared types.
- `platform/k8s-baseline.md`: Kubernetes baseline, observability, and delivery rules.
- `testing/verification-baseline.md`: acceptance checks, failure drills, and performance targets.
- `testing/test-strategy-and-quality-gates.md`: mandatory test layers, quality gates, and what “tests have guarantees” means in this repo.
- `adr/`: frozen architectural decisions that future changes must amend instead of overriding silently.

## Design Change Workflow
1. Update the relevant design doc before or with the first code change.
2. Add or amend an ADR when changing runtime, data ownership, search architecture, AI policy model, or tenant boundaries.
3. Mirror the final design change into the corresponding note under `Obsidian/`.
4. Only then scaffold or modify implementation code.

## Current Baseline
- Runtime: `.NET 10 LTS`
- Deployment: `RKE2 Kubernetes`, single production cluster, multi-node HA
- Transaction source of truth: `PostgreSQL + pgvector`
- Search read-side: `OpenSearch`
- Messaging: `RabbitMQ`
- Realtime: `SignalR`
- Object storage: `MinIO/S3`

# CustomerService

Production-oriented design package for a multi-tenant portable WiFi customer service platform with realtime chat, AI assistance, and chat-history search.

## Start Here
- Formal design authority: [docs/README.md](docs/README.md)
- Learning mirror: [Obsidian/README.md](Obsidian/README.md)
- Hard rules: [AGENTS.md](AGENTS.md)
- Implementation readiness: [docs/architecture/implementation-readiness-and-design-freeze.md](docs/architecture/implementation-readiness-and-design-freeze.md)

Design truth priority is `docs/` > `Obsidian/` > chat memory. `AGENTS.md` adds process and safety constraints.

## Current Baseline
- Runtime: `.NET 10 LTS`
- Deployment: `RKE2 Kubernetes`
- Source of truth: `PostgreSQL + pgvector`
- Search read-side: `OpenSearch`
- Messaging: `RabbitMQ`
- Realtime: `SignalR`
- Object storage: `MinIO/S3`

## Implementation Rule
Do not start scaffolding services or shared contracts until the relevant document set and ADRs under `docs/` have been updated.

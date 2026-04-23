# Kubernetes Baseline

## Cluster Model
- Production baseline: self-managed `RKE2`, single cluster, multi-node HA.
- Node pool separation:
  - `gateway`
  - `core`
  - `ai`
  - `stateful`

## Baseline Platform Components
- `ingress-nginx`
- `cert-manager`
- `Argo CD`
- `Helm`
- `metrics-server`
- `Prometheus`
- `Grafana`
- `Loki`
- `Tempo`
- `OpenTelemetry Collector`

## Deployment Rules
- All services deploy with:
  - readiness and liveness probes
  - resource requests and limits
  - PodDisruptionBudget where applicable
  - topology spread constraints
  - HPA or explicit no-autoscale rationale
- Hot-path stateless services must run with at least `2` replicas in production unless an ADR explicitly carves out an exception.
- `realtime-gateway` ingress must enable WebSocket support and sticky sessions.
- Search indexing workers and search query pods may scale independently.

## Stateful Workloads
- PostgreSQL, OpenSearch, RabbitMQ, and Redis must be isolated from general app workers.
- AI inference or embedding workers must not colocate with search or transaction stateful nodes.
- Stateful components that participate in acknowledged message durability must use HA or replicated deployment patterns appropriate to their role.

## Failure Recovery Baseline
- Single stateless Pod or single worker-node loss must not require manual steps for main chat flow recovery.
- Realtime clients must reconnect and replay from source truth after gateway loss.
- Platform restart behavior must not assume Redis or OpenSearch contain business truth.

## Secrets And Configuration
- Runtime config comes from ConfigMaps and Secrets, but AI policy truth lives in PostgreSQL.
- Secret material never appears in logs, docs examples, or Obsidian notes.

## Observability Baseline
- Required identifiers in logs, traces, and metrics:
  - `tenant_id`
  - `conversation_id`
  - `correlation_id`
  - `message_id`
  - `tool_call_id` when present
- Search, AI, and routing need separate dashboards because they fail differently and scale differently.

## Delivery And Rollout
- GitOps via Argo CD is the default.
- Environment progression:
  - local
  - dev
  - staging
  - production
- Changes to runtime version, OpenSearch topology, PostgreSQL retention, or AI policy publication flow require ADR updates.

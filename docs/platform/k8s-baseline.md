# Kubernetes Baseline（Kubernetes 基线）

## Cluster Model（集群模型）
- 生产基线（production baseline）采用 self-managed `RKE2`，单集群（single cluster）、多节点高可用（multi-node HA）。
- node pool（节点池）按职责分离：
  - `gateway`
  - `core`
  - `ai`
  - `stateful`

## Baseline Platform Components（基础平台组件）
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

## Deployment Rules（部署规则）
- 所有服务部署时都必须带：
  - readiness 和 liveness probes（探针）
  - resource requests / limits（资源请求与限制）
  - 适用时的 `PodDisruptionBudget`
  - topology spread constraints（拓扑分散约束）
  - `HPA` 或显式的 no-autoscale rationale（不自动扩缩容理由）
- hot-path stateless services 在生产环境至少运行 `2` 个副本，除非 ADR 明确给出例外。
- `realtime-gateway` 的 ingress 必须开启 WebSocket support（WebSocket 支持）和 sticky sessions（粘性会话）。
- search indexing workers（搜索索引 worker）和 search query pods（搜索查询 Pod）可以独立扩缩。

## Stateful Workloads（有状态工作负载）
- PostgreSQL、OpenSearch、RabbitMQ 和 Redis 必须与普通应用 worker 隔离部署。
- AI inference（推理）或 embedding workers 不能与 search 或 transaction stateful nodes（事务型状态节点）混部。
- 凡是参与 acknowledged message durability（已确认消息持久化）的 stateful components，都必须使用适合自身角色的 HA 或 replicated deployment patterns（复制部署模式）。

## Failure Recovery Baseline（故障恢复基线）
- 单个 stateless Pod 或单个 worker node 丢失后，主聊天流程恢复不能依赖人工步骤。
- realtime clients 在 gateway 丢失后必须能够 reconnect 并从 source truth replay。
- platform restart behavior（平台重启行为）不能假设 Redis 或 OpenSearch 持有 business truth。

## Secrets And Configuration（密钥与配置）
- runtime config（运行时配置）来自 ConfigMaps 和 Secrets，但 AI policy truth（AI 策略真相）保存在 PostgreSQL。
- secret material（密钥材料）不能出现在 logs、docs examples 或 Obsidian notes 中。

## Observability Baseline（可观测性基线）
- logs、traces 和 metrics 里必须带的 identifiers（标识）包括：
  - `tenant_id`
  - `conversation_id`
  - `correlation_id`
  - `message_id`
  - `tool_call_id`（如果存在）
- search、AI 和 routing 需要分别建设 dashboard（仪表盘），因为它们的故障模式和扩缩方式不同。

## Delivery And Rollout（交付与发布）
- 默认采用 Argo CD 的 GitOps。
- 环境推进顺序（environment progression）是：
  - local
  - dev
  - staging
  - production
- 只要改动 runtime version、OpenSearch topology、PostgreSQL retention 或 AI policy publication flow（AI 策略发布流程），都必须同步更新 ADR。

# P0-02 Engineering Baseline V1

## Goal（目标）
冻结仓库结构、shared building blocks（共享构件）边界、本地开发拓扑、配置分层、CI/CD 和 Helm 约定，确保大范围 scaffolding（脚手架）与后续服务落地都遵守同一套工程基线。

## Why This Blocks Coding（为什么阻塞编码）
- 如果没有统一 engineering baseline（工程基线），每个 service 会各自定义目录、依赖管理、配置方式和发布约定。
- 这类分裂会让 local、CI 和 deployment 规则失去可复现性，后期收口成本很高。

## Scope（范围）
- repository layout（仓库目录）
- solution structure（解决方案结构）
- shared libraries / shared packages 的边界
- local development topology（本地开发拓扑）
- configuration layering by environment（按环境分层的配置）
- CI pipeline stages（持续集成阶段）
- Helm chart / values conventions（Helm 与 values 约定）
- `local` / `dev` / `staging` / `production` 环境矩阵

## Non-Goals（非目标）
- 不在本议题里实现所有脚手架代码。
- 不在本议题里定义各个业务服务的领域模型或 API contract。
- 不重开 Kubernetes baseline、runtime baseline 或 GitOps 是否采用 Argo CD 等已冻结方向。

## Affected Paths（影响路径）
- [docs/architecture/implementation-readiness-and-design-freeze.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-readiness-and-design-freeze.md)
- [docs/architecture/implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [docs/platform/k8s-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/platform/k8s-baseline.md)
- [docs/testing/verification-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/testing/verification-baseline.md)
- 预期新增的 engineering baseline 权威文档或其等价文档

## Constraints（约束）
- 必须兼容 `.NET 10 LTS`、`RKE2 Kubernetes`、GitOps 和现有状态组件职责划分。
- shared building blocks 不能模糊服务边界，不能把 domain truth 重新集中到“万能 shared”。
- 本地拓扑和 CI checks 必须能支撑最小相关验证，而不是只给生产环境留规则。

## Suggested Delivery Order（建议顺序）
1. 先定仓库目录、solution structure 和 shared 边界。
2. 再定本地开发拓扑、配置分层和环境矩阵。
3. 最后定 CI pipeline stages、Helm layout 和 values conventions。

## Acceptance Checks（验收检查）
- 已形成一份权威 engineering baseline 文档，覆盖 repo layout、solution structure、shared 边界、local topology、config layering、CI、Helm、environment matrix。
- 新服务能按文档直接判断应该放在哪、依赖什么、配置怎么分层、最低要跑哪些 checks。
- 本地 bring-up、CI checks 和部署清单约定具备可复现性，而不是每个服务自定义。
- 文档与平台基线、验证基线和现有 Git/branch 规则一致。

## References（参考）
- [implementation-readiness-and-design-freeze.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-readiness-and-design-freeze.md)
- [implementation-freeze-checklist.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/architecture/implementation-freeze-checklist.md)
- [k8s-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/platform/k8s-baseline.md)
- [verification-baseline.md](/C:/Users/GlnyG/.codex/worktrees/c976/CustomerService/docs/testing/verification-baseline.md)

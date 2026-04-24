# Code Review Checklist（代码与文档自查清单）

结束任务前，使用这份清单做 self-review（自查）。

## Correctness（正确性）
- 这次改动解决的是 root cause（根因），还是只处理了表面症状？
- success path（成功路径）和 failure path（失败路径）都被有意识地处理了吗？
- 对于原本不该变化的行为，这次改动有没有无意中改掉？
- 关键 assumptions（假设）是否已经明确写进 code、tests 或 docs？

## Multi-Tenant Safety（多租户安全）
- 是否存在任何请求能读到或写到别的 tenant 的数据？
- query filters、cache keys、events、jobs 是否都正确带 tenant scope（租户范围）？
- 缺少 tenant context 时，是否 fail closed（拒绝）？
- 是否意外引入了 default tenant 或 implicit global path（隐式全局路径）？

## Contracts And Data（合同与数据）
- 如果 API、event、DTO、schema、config contract 改了，所有关联表面（connected surfaces）都更新了吗？
- migrations、backfills、compatibility concerns（兼容性顾虑）是否已经考虑到？
- examples 或 docs 是否在需要时同步更新，以避免误用？

## Reliability（可靠性）
- retries、duplicate deliveries、re-entrancy（重入）风险是否在需要的地方被处理？
- 错误是否足够 explicit（明确），而不是被悄悄吞掉？
- 是否新增了会掩盖真实问题的 brittle fallback logic（脆弱兜底逻辑）？
- 有没有隐藏的 timing、ordering 或 background job coupling（时序/后台耦合）？

## Security And Privacy（安全与隐私）
- 改动之后 authz（授权）还正确吗？
- secrets、tokens、customer PII 是否仍然不会出现在 logs 里？
- 是否有任何 client-controlled input（客户端可控输入）被过早信任？

## Observability And Operations（可观测性与运维）
- 出问题时，能否从 logs、metrics、traces 或 audit records 中看明白？
- 如果改动涉及 AI-human handoff（AI 与人工交接），相关链路是否可追踪？
- 如果改动影响 routing 或 automation，operators（运维/运营）能否理解系统发生了什么？

## Code Quality（代码质量）
- 是否复用了现有模式，而不是发明了新的不必要模式？
- 改完之后，代码或文档是更简单了，还是至少没有更乱？
- names、boundaries、responsibilities 是否清晰？

## Tests（测试）
- 是否至少有一个 test 或 check，在没有这次改动时会失败？
- 如果是 bug fix，是否补了 regression test（在可行时）？
- 如果改的是 policy 或 routing logic，是否同时覆盖了 positive / negative cases？
- 如果涉及 multi-tenant logic，是否覆盖了 wrong-tenant 和 missing-tenant？

## Lessons（经验沉淀）
- 这是不是同类错误第二次出现？
- 如果是，是否在 `docs/lessons.md` 增加了简短 lesson？
- 如果是，是否把一个 durable rule（耐久规则）提升进 `AGENTS.md`？

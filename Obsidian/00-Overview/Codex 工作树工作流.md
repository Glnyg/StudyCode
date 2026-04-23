# Codex 工作树工作流

对应正式文档：`docs/platform/codex-worktree-workflow.md`

## 这是什么
- 这篇讲的是：在 Codex 里，怎么正确使用 [[Git Worktree]] 做多任务开发。
- 重点不是记命令，而是把流程固定成“Codex 能自动执行”的仓库规范。

## 为什么要有这篇
- Codex 经常会在独立工作目录里帮你做事。
- 这些目录本质上就是 [[Git Worktree]]。
- 但很多 worktree 一开始会处于 [[Detached HEAD]]。
- 如果你直接改、不建分支，后面就容易出现：
  - 改动不好合回去
  - 误切分支
  - 把本地工具目录一起提交

## 你先记住 4 件事
1. 主工作树只负责 `main`。
2. 一个 Codex worktree 只做一个任务。
3. 进入 detached worktree 后先建 `codex/<task>` 分支。
4. 合回去时，回主工作树合，不要在 detached worktree 里硬切 `main`。

## 现在仓库怎么自动化
- 仓库里已经加了两个脚本：
  - `scripts/codex/start-worktree-task.ps1`
  - `scripts/codex/finish-worktree-task.ps1`
- 以后 Codex 可以直接调用它们，而不是每次临时拼 git 命令。

## 开始一个任务怎么做
- 如果当前 worktree 是 [[Detached HEAD]]，先运行：

```powershell
powershell -File scripts/codex/start-worktree-task.ps1 -TaskName "architecture-docs"
```

- 这个脚本会自动：
  - 检查当前是不是 detached
  - 生成安全的分支名
  - 创建 `codex/architecture-docs`

## 做完任务怎么收尾
- 提交但先不合并：

```powershell
powershell -File scripts/codex/finish-worktree-task.ps1 -CommitMessage "Add architecture docs"
```

- 提交并自动合回主工作树：

```powershell
powershell -File scripts/codex/finish-worktree-task.ps1 -CommitMessage "Add architecture docs" -Merge
```

## 这个脚本为什么稳
- 它会自动 `git add -A`，但仓库里的 `.gitignore` 已经排除了：
  - `.codex/`
  - `.idea/`
  - `.vs/`
- 所以本地工具目录默认不会被一起带进提交。
- 而且它默认用 `--ff-only` 合并，这样如果主线已经漂移，就会明确失败，不会偷偷搞出你没注意的合并结果。

## 在本项目里怎么用
- 以后只要 Codex 在 worktree 里工作，就按这套固定流程走：
  - 先接管 detached HEAD
  - 再改文档或代码
  - 再跑最小验证
  - 最后提交并按需合回主线

## 工作里怎么用
- 你在真实团队里也可以套这个思路。
- 核心不是“有没有 Codex”，而是：
  - 多任务要隔离
  - 分支要显式
  - 合并入口要统一
  - 本地工具状态要自动忽略

## 面试怎么说
- “我会把 AI 代理的 worktree 流程做成脚本化仓库规范：进入 detached worktree 自动建任务分支，提交时统一走固定脚本，合并回主工作树时用显式策略和忽略规则，避免 AI 临时拼 git 命令带来的不确定性。”

## 你下一步应该看什么
1. [[Git Worktree]]
2. [[Detached HEAD]]
3. [[开工前设计冻结清单]]

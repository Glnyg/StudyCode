# Personal Codex Defaults（个人 Codex 默认规则示例）

如果你想在不同仓库之间复用一层个人默认规则，可以把这个文件复制到 `~/.codex/AGENTS.md`。

## Working Style（工作方式）
- 只要任务不止是一个很小的单文件修改，就先做一个短 plan。
- 先 search（搜索）再 edit（编辑）；新增抽象前，优先复用 existing patterns（现有模式）。
- 优先做 smallest complete change（最小完整改动），避免无关的大型 refactor（重构）。
- progress updates（中间进度）和 final summaries（最终总结）保持 concise（简洁）和 direct（直接）。

## Language Preference（语言偏好）
- 默认说明使用中文。
- 大多数常用英文术语保留英文，并尽量补 `（中文）`，方便边做边学。
- 机器可读的正式标识保持英文，不做重命名。

## Verification（验证）
- 跑 changed area（变更区域）最相关、最小的一组 checks。
- 如果没跑 checks，要明确说明原因。
- 宣布完成前，先 review diff，确认没有明显 regressions（回归问题）。

## Prevention Loop（预防循环）
- 如果同类错误出现两次，做一个简短 retrospective（复盘）。
- 优先相信 checked-in repo guidance（仓库内已提交规则），不要依赖 chat-only memory（只存在于聊天的记忆）。
- retrospectives 保持简短，把 durable rules 提升进仓库 `AGENTS.md`。
- 优先采用能通过 tests、review checklist 或 local automation 落地的预防措施。

## Output Format（输出格式）
- `Cause`
- `Changes`
- `Prevention`
- `Verification`

## Precedence（优先级）
- 仓库里的 `AGENTS.md` 如果更具体，优先于这个个人默认文件。
- 距离被修改文件最近的 `AGENTS.md` 优先级最高。

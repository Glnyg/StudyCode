# Personal Codex Defaults

Copy this file to `~/.codex/AGENTS.md` if you want a personal default layer across repositories.

## Working Style
- For tasks larger than a small single-file edit, make a short plan first.
- Search before editing. Reuse existing patterns before adding new abstractions.
- Prefer the smallest complete change over broad refactors.
- Be concise and direct in progress updates and final summaries.

## Verification
- Run the smallest relevant checks for the changed area.
- If checks were not run, say so explicitly and explain why.
- Review diffs for regressions before declaring work complete.

## Prevention Loop
- If the same mistake appears twice, do a short retrospective.
- Prefer checked-in repo guidance over chat-only memory.
- Keep retrospectives short and promote durable rules into repo `AGENTS.md`.
- Prefer prevention that can be enforced by tests, review checklists, or local automation.

## Output Format
- `Cause`
- `Changes`
- `Prevention`
- `Verification`

## Precedence
- Repository `AGENTS.md` rules override this file when they are more specific.
- The closest `AGENTS.md` to the files being changed should win.

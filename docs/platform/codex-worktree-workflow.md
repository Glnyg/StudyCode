# Codex Worktree Workflow

## Goal
Make Codex worktree usage deterministic and executable so routine task branches, commits, and merges do not depend on ad hoc shell memory.

## Why This Exists
- Codex commonly works inside `git worktree` directories.
- Those worktrees may start in `detached HEAD`.
- Detached work without an explicit branch is easy to lose or merge incorrectly.
- Local agent state such as `.codex/` and IDE state such as `.idea/` should not be merged into the repository.

## Standard Repository Rules
- Keep the primary repository root on `main`.
- Use one Codex worktree per task.
- Create a task branch before substantial edits if the worktree is in `detached HEAD`.
- Default branch pattern is `codex/<task-slug>`.
- Merge back through the primary `main` worktree, not by checking out `main` inside a detached Codex worktree.
- Ignore local-only directories in `.gitignore`:
  - `.codex/`
  - `.idea/`
  - `.vs/`

## Script Entry Points
- start task branch:
  - `powershell -File scripts/codex/start-worktree-task.ps1 -TaskName "architecture-docs"`
- finalize task branch without merge:
  - `powershell -File scripts/codex/finish-worktree-task.ps1 -CommitMessage "Add architecture docs"`
- finalize and merge into the main worktree:
  - `powershell -File scripts/codex/finish-worktree-task.ps1 -CommitMessage "Add architecture docs" -Merge`

## What The Start Script Does
- verifies the current worktree state
- refuses to auto-switch away from an existing named branch
- converts the task name into a safe branch slug
- creates `codex/<task-slug>` from the current `HEAD`

## What The Finish Script Does
- requires the current worktree to be on a named branch
- stages repository changes with `git add -A`
- relies on `.gitignore` to exclude local-only directories
- creates a commit when staged changes exist
- optionally finds the worktree currently holding `main`
- merges the task branch into `main` with `--ff-only`

## Normal Codex Flow
1. Codex enters a task worktree.
2. Codex checks whether `git branch --show-current` is empty.
3. If the worktree is detached, Codex runs the start script first.
4. Codex performs the requested work.
5. Codex runs the smallest relevant checks.
6. If the user wants the work merged back, Codex runs the finish script with `-Merge`.

## Safety Rules
- Do not merge from a dirty primary `main` worktree.
- Do not stage or commit `.codex/`, `.idea/`, or other local-only tool state.
- Do not use `git checkout main` inside a detached Codex worktree as a substitute for proper merge flow.
- If `--ff-only` merge fails, stop and resolve branch drift intentionally instead of hiding it.

## Expected Failure Cases
- branch already exists:
  - choose a new task name or reuse the existing branch intentionally
- current worktree already on another branch:
  - stop and decide whether this task belongs on that branch
- target `main` worktree not found:
  - open or create the primary worktree on `main` first
- target `main` worktree dirty:
  - clean it before merge

## Governance
- Codex should prefer these scripts over ad hoc manual git command sequences for routine worktree lifecycle handling in this repository.
- If the workflow changes, update:
  - `.gitignore`
  - `AGENTS.md`
  - this document
  - the matching Obsidian note

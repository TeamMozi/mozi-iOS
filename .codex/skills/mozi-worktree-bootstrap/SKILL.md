---
name: mozi-worktree-bootstrap
description: Enforce Mozi worktree first-entry setup before any response or task. Use at session start in Mozi worktrees, when the cwd is under a Mozi git worktree, when detached HEAD is present, or when Config/*.xcconfig or Mozi.xcworkspace is missing.
---

# Mozi Worktree Bootstrap

Mozi project hard gate so `./scripts/setup-worktree.sh` is never skipped on first entry.

## Read First

- `AGENTS.md` section `0. Worktree Hard Gate`
- `AGENTS.md` section `8. Worktree`

## When This Applies

Apply immediately when cwd looks like a Mozi repo worktree:

- path contains `모지(mozi)` or repo root has `Workspace.swift` + `Projects/` + `scripts/setup-worktree.sh`
- especially Codex worktree paths like `~/.codex/worktrees/<id>/...`

Also apply on the first user message in such a session.

## Hard Gates

1. Before any normal reply or task work, check ready state.
2. If not ready, run `./scripts/setup-worktree.sh` first.
3. Do not answer the user request until setup finishes or ready is confirmed.
4. If already ready, skip setup and continue.
5. Use script flags only when the user explicitly asks (e.g. `--skip-build`).

## Ready Check

Ready only if all are true:

1. `git rev-parse --abbrev-ref HEAD` is not `HEAD`
2. `Config/Debug.xcconfig` exists
3. `Config/Release.xcconfig` exists
4. `Mozi.xcworkspace` exists

Quick check example:

```bash
git rev-parse --abbrev-ref HEAD
test -f Config/Debug.xcconfig && test -f Config/Release.xcconfig && test -d Mozi.xcworkspace
```

## Flow

```text
session/message starts in Mozi worktree
  → ready check
  → not ready? run ./scripts/setup-worktree.sh
  → report one-line result
  → continue with user request
```

## Report Style

After setup, one short line is enough:

```text
worktree ready: branch=codex/5815, config=ok, workspace=ok
```

If already ready:

```text
worktree already ready: branch=...
```

## Non-Goals

- Do not invent alternate bootstrap steps.
- Do not re-run setup every message when already ready.

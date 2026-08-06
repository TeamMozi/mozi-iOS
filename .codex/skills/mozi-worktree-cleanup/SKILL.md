---
name: mozi-worktree-cleanup
description: Clean up a Mozi feature worktree and local branch after the PR is merged. Use in the Mozi repo when the user says "워크트리 정리해", "머지됐으니 정리해", "로컬 정리해", "worktree 지워", or asks to remove a finished worktree/branch safely after merge.
---

# Mozi Worktree Cleanup

PR 머지 후 로컬 worktree / 브랜치를 안전하게 정리한다.

## Read First

- `docs/AGENT_WORKFLOW.md`
- `docs/skills.md`
- `AGENTS.md` Worktree / Git section

## Effort Policy

- model: inherit the current session start model; do not switch models
- effort: `low`
- do not use `max`/`ultra`
- if the current session effort is higher, prefer continuing at `low` for this skill work

SSOT: `docs/AGENT_WORKFLOW.md` Model / Effort Policy

## Trigger Phrases

Use this skill when the user says things like:

- `워크트리 정리해`
- `머지됐으니 정리해`
- `로컬 정리해`
- `worktree 지워`
- `정리해` in a finished-PR context

## Hard Gates

1. Do not delete anything before checking merge state.
2. Only clean up when the related PR is actually **merged**.
3. If the PR is open/closed-unmerged, stop and report.
4. If the worktree is dirty, stop and report. Do not auto-stash or discard.
5. If there are unpushed local commits, stop and report.
6. Never remove the main checkout worktree.
7. Prefer safe deletes:
   - `git worktree remove <path>`
   - `git branch -d <branch>`
   - `git fetch --prune`
8. Use force only when the user explicitly asks:
   - `git worktree remove --force`
   - `git branch -D`
9. Show a cleanup plan once, get approval, then execute.
10. Do not merge/close PRs from this skill.

## What To Identify

Before planning, resolve:

- current branch
- current worktree path
- main repo path (`git rev-parse --git-common-dir`)
- linked PR number/url if available
- PR state / mergedAt / base branch
- dirty state
- unpushed commits
- whether remote branch still exists

Helpful commands:

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --porcelain
git rev-parse --git-common-dir
git worktree list --porcelain
gh pr view --json number,url,state,mergedAt,baseRefName,headRefName
git log --oneline @{u}..HEAD 2>/dev/null || true
git fetch origin --prune
```

## Cleanup Plan Format

```text
1. 대상 확인
   - worktree: <path>
   - branch: <branch>
   - PR: <url> (merged)
2. 안전 검사
   - dirty: none
   - unpushed: none
3. 실행
   - git worktree remove <path>
   - git branch -d <branch>
   - git fetch --prune
```

## Flow

```text
정리해
  → 현재 worktree/branch/PR 확인
  → merged 아니면 중단
  → dirty/unpushed 있으면 중단
  → 정리 계획 제시
  → 1회 승인
  → worktree remove
  → local branch delete
  → fetch --prune
  → 결과 보고
```

## Execution Notes

### Preferred order

1. Confirm PR merged into expected base (`dev`)
2. Ensure clean tree
3. Ensure no unpushed commits
4. Remove worktree from a different checkout when needed
5. Delete local branch with `-d`
6. Prune remote-tracking branches

### If currently inside the target worktree

Do not try to delete the current directory from inside itself blindly.

Preferred:

1. move to main repo root
2. `git worktree remove <target-path>`
3. `git branch -d <branch>`

### Main checkout protection

If the target path is the primary non-linked checkout, do **not** remove it.
Only delete linked worktrees.

## Refusal / Stop Snippets

### PR not merged

```text
아직 머지되지 않았습니다. 머지된 뒤에 로컬 정리를 진행할게요.
```

### Dirty worktree

```text
worktree에 커밋되지 않은 변경이 있습니다. 정리 전에 처리가 필요해요.
```

### Unpushed commits

```text
로컬에 푸시되지 않은 커밋이 있습니다. 삭제 전에 확인이 필요해요.
```

### Force requested without explicit wording

```text
강제 삭제는 명시 요청이 있을 때만 합니다. force로 정리할까요?
```

## Output

- cleanup plan
- execution result
- removed worktree path
- deleted local branch
- remaining related refs if any

## Non-Goals

- Do not auto-merge PR
- Do not bulk-clean unrelated worktrees
- Do not discard dirty changes
- Do not force-delete by default

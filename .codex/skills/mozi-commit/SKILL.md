---
name: mozi-commit
description: Plan and create Mozi title-only, intent-scoped commits with a one-time approval gate. Use in the Mozi repo when the user says "커밋해", asks for a commit plan, wants commits split by intent, or needs commit messages that read cleanly in the commit graph; also when preventing unsolicited staging/commit/push.
---

# Mozi Commit

Mozi project commit hard gates and style.

## Read First

- `docs/AGENT_WORKFLOW.md`
- `docs/CONVENTIONS.md`
- `AGENTS.md` Git / PR section

## Hard Gates

1. Do not start commit work until the user says `커밋해` (or an explicit equivalent like `커밋 진행해`).
2. Before approval, only read git state (`status`, `diff`, log as needed).
3. Never stage, commit, amend, or push before the commit plan is approved once.
4. After one plan approval, execute the approved commits continuously.
5. If the plan drifts slightly, make the smallest reasonable adjustment and continue; re-ask only when meaning materially changes.

## Flow

1. Inspect changes read-only.
2. Propose a commit plan.
3. Wait for one approval.
4. Stage and commit per approved plan.
5. Report the resulting commits.

## Plan Format

```text
1. Type: 요약
   - 의도: one line
   - 파일: path1, path2
2. Type: 요약
   - 의도: one line
   - 파일: path3
```

## Message Rules

- Format: `Type: 요약`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Language: Korean
- Title only; no commit body
- One intent per commit
- Split implementation / test / docs / config into separate commits
- Goal: commit graph alone should explain the change flow

## Never Commit Casually

- Prefer explicit paths over `git add -A` / `git add .`
- Do not commit local secrets or ignored config values
- Do not push
- Do not create a PR from this skill

## Refusal Snippets

If asked to inspect without `커밋해`:

```text
아직 커밋 요청 전입니다. 커밋해 라고 하면 변경 확인 후 커밋 계획부터 제안할게요.
```

If user wants body text:

```text
커밋 본문은 쓰지 않습니다. 제목만으로 의도가 읽히게 나누겠습니다.
```

## Output

- commit plan
- approved plan execution result
- final commit list

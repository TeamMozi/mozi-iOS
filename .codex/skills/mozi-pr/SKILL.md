---
name: mozi-pr
description: Draft Mozi PR bodies or create open PRs with hard intent gates, noun-form style, single label, self-assignee, and origin/dev rebase before PR push. Use in the Mozi repo when the user says "PR 초안", "초안 작성", "작성만", "PR 생성해", "PR 올려", "올려", or asks to prepare/create a pull request without jumping ahead.
---

# Mozi PR

Mozi project PR hard gates and style.

## Read First

- `docs/AGENT_WORKFLOW.md`
- `docs/CONVENTIONS.md`
- `.github/pull_request_template.md`
- `AGENTS.md` Git / PR section

## Effort Policy

- model: inherit the current session start model; do not switch models
- effort: `medium` for draft and create
- do not use `max`/`ultra`
- if the current session effort is higher, prefer continuing at `medium` for this skill work

SSOT: `docs/AGENT_WORKFLOW.md` Model / Effort Policy

## Phrase Mapping

### Draft only (no publish)

Treat as body draft in chat only:

- `PR 초안`
- `초안 작성해봐`
- `작성만 해봐`
- similar: `초안`, `작성만`, `본문만`, `어떻게 쓸지 먼저`

Allowed:
- draft title/body in chat
- fill template sections
- style edits

Forbidden:
- git commit
- git push
- creating a GitHub PR (draft or open)
- yeet/finish publish steps

### Create PR

Only these mean real PR creation:

- `PR 생성해`
- `PR 올려`
- `올려`

Create **open** PRs only. Never create draft PRs by interpretation.

## Hard Gates

### Draft ≠ create
If the request is draft-only, stop after showing the body.

### Create requires readiness
On create triggers:

1. Check commit/push state first.
2. If not committed/pushed, stop with:

```text
아직 커밋/푸시 전입니다. 커밋해 라고 하면 커밋 계획부터 시작할게요.
```

3. Do not chain commit/push automatically just to finish the PR.
4. For commits, hand off to `$mozi-commit`.

### Rebase before PR push
When push is needed as part of PR publish:

1. `fetch origin/dev`
2. rebase current branch onto latest `origin/dev`
3. push only after clean rebase
4. on conflict: stop immediately, never auto-resolve

Conflict snippet:

```text
origin/dev 기준 rebase 중 충돌이 났습니다.
자동 처리는 하지 않았습니다.
충돌 파일/상태를 확인한 뒤 어떻게 할지 알려 주세요.
```

## Draft / Body Style

Use noun-form endings for:

- PR title
- `변경 요약` bullets
- `변경 내용` bullets

Template:

```markdown
## 📌 변경 요약
- ...

## 📌 변경 내용
#### 영역 A
- ...
```

Rules:

- `변경 요약`: about 3 bullets
- `변경 내용`: split by module/area; show file/folder/role
- `기타 참고 사항` is optional; delete the whole section if empty
- no operational meta in body (`base`, `head`, branch names, commit hashes)

good: `RootFeature 부트스트랩 상태 추가`  
bad: `RootFeature 부트스트랩 상태를 추가했습니다`

## Create-Time Meta

Only when actually creating a PR:

1. Map exactly **one** label from repo labels
2. If label mapping is ambiguous, show candidates and ask
3. Assignee = current user always
4. Do not set reviewers/milestone/projects unless asked
5. Create open PR
6. Report title, url, label, assignee

## Flow Cheatsheets

### Draft request

```text
draft phrase
  → write body in chat with noun-form style
  → stop
```

### Create request

```text
create phrase
  → verify commit/push readiness
  → if push needed: fetch+rebase origin/dev
  → conflict? stop
  → push
  → choose 1 label + self assignee
  → create open PR
  → report
```

## Non-Goals

- Do not interpret "초안" as GitHub draft PR.
- Do not force-push to hide rebase problems without explicit approval.
- Do not attach multiple labels.

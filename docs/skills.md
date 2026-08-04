# Mozi Skills

Mozi workflow를 반복 실행하기 위한 Codex project skills.

스킬 본문 위치:

```text
.codex/skills/
├── mozi-worktree-bootstrap/
├── mozi-commit/
├── mozi-pr/
└── mozi-worktree-cleanup/
```

## Skills

| skill | 쓰는 시점 | 하지 않을 것 |
|-------|-----------|--------------|
| `mozi-worktree-bootstrap` | Mozi worktree 세션 시작/미준비 상태 | ready 인데 setup 재실행, 대체 bootstrap 절차 발명 |
| `mozi-commit` | 사용자가 `커밋해`라고 했을 때 | `커밋해` 전 staging/commit, 계획 전 린트 생략, body 작성, 여러 의도 혼합 |
| `mozi-pr` | `PR 초안` / `작성만` / `PR 생성해` / `PR 올려` | 초안 요청에서 PR 생성, draft PR 해석, 충돌 자동 resolve |
| `mozi-worktree-cleanup` | PR 머지 후 로컬 worktree/브랜치 정리 | 미머지 상태 삭제, dirty 변경 자동 폐기, force 기본 사용 |

## 기준 문서

- [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md)
- [CONVENTIONS.md](CONVENTIONS.md)
- [../AGENTS.md](../AGENTS.md)
- [../.github/pull_request_template.md](../.github/pull_request_template.md)

## 기준

- worktree: ready 아니면 `./scripts/setup-worktree.sh` 먼저
- 커밋: 계획 전 로컬 린트 1회, `Type: 요약`, 한국어, 제목만, 한 의도 = 한 커밋
- PR 초안: 본문만
- PR 생성: open PR, label 1개, assignee = 본인
- PR push 전: `origin/dev` rebase, 충돌 시 중단
- 머지 후 정리: merged 확인 후 worktree/local branch 안전 삭제

# Mozi Skills

Mozi workflow를 반복 실행하기 위한 Codex project skills.

스킬 본문 위치:

```text
.codex/skills/
├── mozi-commit/
├── mozi-feature-split/
├── mozi-pr/
└── mozi-worktree-cleanup/
```

## Skills

| skill | 쓰는 시점 | 하지 않을 것 |
|-------|-----------|--------------|
| `mozi-commit` | 사용자가 `커밋해`라고 했을 때 | `커밋해` 전 staging/commit, 계획 전 린트 생략, body 작성, 여러 의도 혼합 |
| `mozi-feature-split` | `기능 분해해` / `사이클 나눠줘` / `PR 단위로 쪼개줘` / `Cycle ... 워크트리/세션 만들어` | 분해 단계에서 구현/생성, 저장 전 spawn, 범위 없는 일괄 생성, 기존 worktree 덮어쓰기 |
| `mozi-pr` | `PR 초안` / `작성만` / `PR 생성해` / `PR 올려` | 초안 요청에서 PR 생성, draft PR 해석, 충돌 자동 resolve |
| `mozi-worktree-cleanup` | PR 머지 후 로컬 worktree/브랜치 정리 | 미머지 상태 삭제, dirty 변경 자동 폐기, force 기본 사용 |

## 기준 문서

- [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) — hard gate, Agent Behavior, runtime flow
- [CONVENTIONS.md](CONVENTIONS.md) — 형식/작성규칙 SSOT
- [ARCHITECTURE.md](ARCHITECTURE.md) — 구조/의존/흐름
- [../AGENTS.md](../AGENTS.md)
- [../.github/pull_request_template.md](../.github/pull_request_template.md)

자세한 hard gate와 Agent Behavior는 [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md)를 참조.

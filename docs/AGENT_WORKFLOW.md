# Agent Workflow

Mozi 작업 시 에이전트 hard gate, 행동 원칙, runtime flow의 single source of truth.

## 기준 문서

- [CONVENTIONS.md](CONVENTIONS.md) — 형식/작성규칙 SSOT
- [ARCHITECTURE.md](ARCHITECTURE.md) — 구조/의존/흐름 SSOT
- [skills.md](skills.md) — skill 인덱스
- project skills: `.codex/skills/mozi-commit`, `.codex/skills/mozi-feature-split`, `.codex/skills/mozi-pr`, `.codex/skills/mozi-worktree-cleanup`
- [../AGENTS.md](../AGENTS.md)

## 1. Hard Gates

### 커밋

1. `커밋해` 전에는 staging/commit/push 시작 금지.
2. 계획 단계에서는 `git status` / `git diff` 읽기만 허용.
3. 커밋 계획 제안 전 로컬 린트 1회: `mise exec -- swiftlint lint --strict`
4. 린트 실패 시 계획 제안 중단, 위반 사항 보고.
5. 커밋 계획(제목 + 의도 + 파일) 1회 승인 후 진행.
6. 커밋 메시지: `Type: 요약` (한국어, 제목만, body 금지).
7. 한 의도 = 한 커밋 (구현/테스트/문서/설정 분리).

커밋 요청 시 `$mozi-commit` 스킬을 사용한다.

### feature split

1. `기능 분해해` / `사이클 나눠줘` / `PR 단위로 쪼개줘` 는 분해 단계다.
2. 분해 단계에서는 코드 수정, worktree/session 생성, commit/PR 금지.
3. 분해 초안 + 파일명 1회 승인 후 `docs/superpowers/splits/` 에 저장한다.
4. 생성 단계 트리거: `Cycle ... 워크트리/세션 만들어` / `ready한 거 전부 만들어`.
5. 생성은 저장된 split 문서가 있을 때만, 생성 계획 1회 승인 후 진행한다.
6. 기본은 지정 Cycle만 생성. 범위 없으면 되묻고, `ready 전부`만 일괄 생성한다.
7. 기존 같은 branch/worktree가 있으면 중단한다. 덮어쓰지 않는다.

기능 분해/분기 요청 시 `$mozi-feature-split` 스킬을 사용한다.

### PR

1. `PR 초안` / `작성만` = 본문 초안만 제시.
2. 위 단계에서는 commit/push/PR 생성 금지.
3. 실제 생성 트리거: `PR 생성해` / `PR 올려` / `올려`.
4. push 직전: `origin/dev` rebase. 충돌 시 즉시 중단.
5. PR는 open PR만 (draft 해석 금지), label 1개, self assignee.

PR 요청 시 `$mozi-pr` 스킬을 사용한다.

### worktree cleanup

1. `워크트리 정리해` / `머지됐으니 정리해` / `로컬 정리해` 전에는 삭제 금지.
2. 관련 PR이 **merged**인지 먼저 확인.
3. dirty worktree 또는 unpushed commit 있으면 중단.
4. 안전 삭제(`worktree remove`, `branch -d`).

머지 후 정리 요청 시 `$mozi-worktree-cleanup` 스킬을 사용한다.

## 1.5 Model / Effort Policy

Mozi 워크플로우는 **세션 시작 model 을 상속**하고, 단계마다 **reasoning effort 만** 다르게 쓴다.
model slug 를 문서에 하드코딩하지 않는다.

### 고정 규칙

1. model: 현재 세션 시작 model 을 그대로 따른다 (임의 교체 금지)
2. 기본 effort: `medium`
3. `max` / `ultra` 사용 금지
4. child session / subagent 는 model 을 부모에서 상속하고, effort 만 단계값으로 명시한다
5. 설계가 끝나면 긴 high 세션을 유지하지 말고 `medium` 으로 복귀한다

### 단계 매핑

| 단계 | effort |
|------|--------|
| brainstorm / architecture / design | `high` |
| writing plans | `medium` (모호하면 `high`) |
| feature split (`기능 분해해`) | `medium` |
| Cycle spawn / brief 작성 | `low` ~ `medium` |
| implement 기계적 (plan 상세, 1~2 파일) | `low` |
| implement 통합/TCA/다중파일 | `medium` |
| debug 난이도 높음 | `high` |
| code review | `high` |
| small fix re-review | `low` ~ `medium` |
| commit (`mozi-commit`) | `low` |
| PR 초안/생성 (`mozi-pr`) | `medium` |
| worktree cleanup | `low` |

### 운영 한 줄

```text
model = session start model (inherit)
design/review = high
default/implement = medium
mechanical/ops = low
never max/ultra
```

### 적용 위치

- 메인 코디네이터 기본: 세션 시작 model + `medium`
- Cycle child session 생성 시 model 상속, effort 명시
- Superpowers implement/review subagent 생성 시 model 상속, effort 명시
- Mozi skill 실행 시 해당 skill 의 effort 규칙을 따른다

## 2. Agent Behavior

1. 작업 시작 시 문서 우선순위와 관련 source of truth를 확인한다.
2. 규칙이 충돌하면 해당 주제의 source of truth 파일을 우선한다.
   - 구조: ARCHITECTURE.md
   - 작성 규칙: CONVENTIONS.md
   - 실행/hard gate: AGENT_WORKFLOW.md
   - 모듈 디테일: Projects/**/README.md
3. 전역 지도와 모듈 디테일을 구분해서 읽는다.
4. 요구가 모호하면 추측 구현하지 않고 질문한다.
5. 코드와 문서가 다르면 현재 코드 기준으로 보고하고, 문서 수정 필요 여부를 제안한다.
6. 문서 변경 시 중복 본문을 늘리지 않고 링크를 유지한다.
7. model/effort 선택이 필요하면 위 Model / Effort Policy 를 따른다. model 은 세션 시작값을 유지하고 effort 만 조절한다.

## 3. Runtime Flow

### 커밋

```
커밋해
  → 변경 확인
  → 로컬 린트 (`mise exec -- swiftlint lint --strict`)
  → 계획 제안
  → 1회 승인
  → 연속 커밋
  → 결과 보고
```

### feature split

```
기능 분해해
  → 작은 작업이면 분해 불필요 판정
  → 얇은 전체 방향 확인
  → Cycle 분해 + brief
  → 분해 초안 + 파일명 제안
  → 1회 승인
  → docs/superpowers/splits 저장
  → 다음 메뉴
```

### feature spawn

```
Cycle ... 워크트리/세션 만들어
  → 저장된 split 문서 확인
  → 생성 계획
  → 1회 승인
  → worktree/branch 생성
  → session 생성 + brief + brainstorming 시작
  → Spawned 갱신
  → 결과 보고
```

### PR 초안

```
PR 초안 / 작성만
  → 본문 초안 제시
  → 종료
```

### PR 생성

```
PR 생성해 / PR 올려 / 올려
  → 커밋/푸시 상태 확인
  → push 필요 시 origin/dev rebase
  → 충돌 시 중단
  → open PR 생성 (label 1 + self assignee)
  → 결과 보고
```

### worktree cleanup

```
워크트리 정리해 / 머지됐으니 정리해
  → PR merged 확인
  → dirty/unpushed 검사
  → 정리 계획 제시
  → 1회 승인
  → worktree/local branch 안전 삭제
  → 결과 보고
```

## 4. Non-Goals

- 전역 Superpowers plugin 수정 없음
- 도구 경로 고정 규칙은 아직 적용하지 않음
- document rule 전부를 hard gate로 격상하지 않음

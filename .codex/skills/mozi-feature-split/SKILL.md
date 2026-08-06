---
name: mozi-feature-split
description: Split a large Mozi feature into independent Cycles and PR candidates, write a local split document, prepare child-session briefs, and only after explicit approval create worktrees/sessions. Use in the Mozi repo when the user says "기능 분해해", "사이클 나눠줘", "PR 단위로 쪼개줘", "독립 사이클로 나눠줘", "병렬 가능한 작업 나눠줘", "하위 세션 brief 만들어줘", "split 문서 저장해", "Cycle ... 워크트리/세션 만들어", "ready한 거 전부 만들어", or when a large feature signal appears and the user accepts a split suggestion.
---

# Mozi Feature Split

큰 Mozi 기능을 독립 Cycle / PR 후보로 분해하고, 필요 시 worktree + Codex 세션으로 분기한다.

## Read First

- `docs/AGENT_WORKFLOW.md`
- `docs/ARCHITECTURE.md`
- `docs/CONVENTIONS.md`
- `docs/skills.md`
- `AGENTS.md`

## Phrase Mapping

### Split stage

Treat as split-only:

- `기능 분해해`
- `사이클 나눠줘`
- `PR 단위로 쪼개줘`
- `독립 사이클로 나눠줘`
- `병렬 가능한 작업 나눠줘`
- `하위 세션 brief 만들어줘`
- `split 문서 저장해`
- `분해 문서 저장해`
- similar: `나눠줘`, `쪼개줘`, `분해해`

Allowed:

- codebase/docs survey
- thin overall direction capture
- Cycle decomposition
- child-session brief drafting
- split document save after approval

Forbidden:

- code edits
- worktree/session creation
- commit / push / PR

### Spawn stage

Only these mean real creation:

- `Cycle <id> 워크트리/세션 만들어`
- `Cycle <id> 생성해`
- `이 Cycle 분기해`
- `ready한 거 전부 만들어`
- `ready Cycle 생성해`
- `분기 가능한 거 다 열어`

Plan-only phrases:

- `생성 계획만`
- `분기 계획만`

### Situational signal

If the user only signals a large task, do **not** auto-run.

Examples:

- `홈화면 기능을 맡았어`
- `이 기능 한번에 하기엔 크다`
- `메인에서 먼저 나눠줘`

Respond with a short offer:

```text
이 작업은 mozi-feature-split 으로 먼저 나누는 게 좋아 보여요.
분해 진행할까요?
```

Run only after yes.

## Effort Policy

Inherit the session start model. Change effort only.

| stage | effort |
|-------|--------|
| split (`기능 분해해`) | `medium` |
| spawn plan / brief drafting | `low` ~ `medium` |
| child session start (brainstorm/design) | `high` |
| child implement after plan approval | `low` (mechanical) or `medium` (integration) |
| child review | `high` |
| commit/PR later in child | follow `$mozi-commit` / `$mozi-pr` |

Rules:

1. Do not switch models mid-workflow. Keep the session start model.
2. Never use `max` / `ultra`.
3. When creating a child session/thread, inherit the parent model and set thinking/effort explicitly.
4. Child starts at `high` for brainstorming only; after plan approval, continue implement at `low`/`medium`.
5. Main session default remains `medium`.

SSOT: `docs/AGENT_WORKFLOW.md` Model / Effort Policy

## Hard Gates

1. Split ≠ spawn. Split stage never creates worktrees/sessions.
2. Split stage never edits product code and never commits/PRs.
3. Save split docs only after one approval of `분해 초안 + 파일명`.
4. Spawn requires an already saved split document.
5. Spawn requires a creation plan and one approval.
6. Default spawn target is only the specified Cycle.
7. If spawn scope is missing, ask. Do not guess multi-create.
8. `ready 전부` is allowed only with explicit wording.
9. Existing same branch/worktree → stop and report. No overwrite, no auto-rename.
10. Multi-create is sequential. On failure, keep completed items, skip the rest, report.
11. Session creation failure after successful worktree is partial success. Do not roll back worktree.
12. Base branch defaults to `origin/dev` unless the user explicitly overrides.
13. Child sessions start with brief + automatic `$superpowers:brainstorming` for that Cycle only.
14. Main session tracks opened Cycle/worktree/session lightly. No active monitoring/orchestration.
15. Create child sessions by inheriting the parent model and setting thinking/effort explicitly: thinking=`high` for Cycle brainstorm start.
16. After child plan approval, drop implement effort to `low`/`medium` per complexity. Keep review at `high`.

## Small Work Guard

Before splitting, judge whether split is needed.

If a single Cycle/PR is enough:

```text
이 작업은 단일 Cycle/PR로 충분합니다. 분해하지 않는 걸 추천해요.
그래도 분해를 진행할까요?
```

Proceed only if the user still wants it.

## Thin Overall Direction

Before decomposition, capture or confirm:

1. 이번 목표
2. 이번 배치에서 빼는 것
3. 완료로 볼 기준
4. 우선 사용자 시나리오 1~2개
5. 반드시 지킬 제약

If blocked, ask 1~2 questions. Otherwise state assumptions and continue.

Do **not** deep-design the whole feature in the main session.
Detailed design belongs to each Cycle's brainstorming.

## Survey Depth

Before splitting, inspect at medium depth:

- `docs/ARCHITECTURE.md`
- related Feature / Domain / Data locations
- similar existing patterns
- forbidden dependency directions

Do not implement while surveying.

## Mozi Split Rules

Hard rules:

1. If a Domain contract is needed, separate it first as `Cycle 0`.
2. Feature UI and Data/API live may run in parallel only after the contract exists.
3. App live assembly is usually last.
4. Reject splits that require forbidden deps:
   - Feature → Data / Core* / ThirdPartyCore
   - Domain → Data / Core* / Feature
   - Data → Feature
5. Prefer one Cycle ≈ one PR candidate.
6. Reject review-impossible blobs like “홈화면 전체” without further split.
7. Cycle 0 / foundation placement:
   - thin shared contract → prefer main session
   - large PR candidate → prefer child session
   - skill recommends, user chooses

## Cycle Model

### Numbering

```text
Cycle 0       기반/계약
Cycle 1, 2    직렬 단계
Cycle 1a/1b   같은 단계의 병렬 트랙
```

### Required card fields

Every Cycle card must include:

- Cycle 이름
- 목표 1줄
- in scope
- out of scope
- 의존 Cycle
- 직렬/병렬
- ready 여부
- PR 후보 여부
- 건드릴 모듈
- 완료 기준
- 제안 branch / worktree
- 하위 세션 brief
- 얇은 설계 힌트 2~3줄

### Ready criteria

Ready when all are true:

- goal is clear
- low file conflict with other open Cycles
- in/out of scope clear
- dependency Cycles are none or already done
- required Domain contract already exists

### PR candidate criteria

`PR 후보: yes` when:

- reviewable alone
- merge does not leave the app badly broken
- in/out of scope clear
- completion criteria exist

Otherwise mark no, or recommend bundling with another Cycle.

## Naming Rules

Branch follows `docs/CONVENTIONS.md`:

```text
Type/짧은-설명
```

Type auto-selection:

- implementation Cycle → `feat/`
- docs-only → `docs/`
- structure/config → `chore/`

Worktree path:

```text
.worktrees/Type-짧은-설명
```

Examples:

```text
branch:   feat/home-ui
worktree: .worktrees/feat-home-ui

branch:   chore/home-domain-contract
worktree: .worktrees/chore-home-domain-contract
```

Base:

```text
default: origin/dev
override: only when user explicitly sets base
```

## Split Document

### Path

```text
docs/superpowers/splits/YYYY-MM-DD-<feature>-split.md
```

Example:

```text
docs/superpowers/splits/2026-08-06-home-feature-split.md
```

Notes:

- local-only under ignored `docs/superpowers/`
- do not commit from this skill

### Re-split behavior

If a same-feature split already exists, ask:

```text
기존 split 문서가 있습니다.
1. 기존 문서 업데이트
2. 새 문서로 저장
```

Do not silently overwrite.

### Document skeleton

```markdown
# <Feature> Split

## 1. 목표

## 2. 전제 / 가정

## 3. Cycle 목록

## 4. 의존 / 병렬 지도

## 5. 지금 할 일

## 6. Cycle 상세

### Cycle 0: ...
...

## 7. Spawned

- 없음
```

### Spawned update

After successful or partial spawn, update section 7 with:

```markdown
## 7. Spawned

- Cycle 1a: opened
  - branch: feat/home-ui
  - worktree: .worktrees/feat-home-ui
  - session: <id or url or manual>
  - note: session failed; worktree ready
```

## Chat Output Shape

Chat is a summary, not the full document dump.

Include:

1. thin overall direction / assumptions
2. Cycle list with:
   - goal
   - deps
   - serial/parallel
   - ready
   - PR candidate
   - branch/worktree
3. dependency/parallel map
4. now/next recommendation
5. brief summaries, not full briefs
6. proposed split filename

Full cards + full briefs go into the split document.

## Approval Flow

### Split save

```text
분해 초안 + 파일명 제안
→ 1회 승인
→ docs/superpowers/splits/... 저장
→ 짧은 다음 메뉴
```

Post-save menu:

```text
저장했습니다.
다음 중 골라주세요.
1. ready Cycle 생성 계획
2. 특정 Cycle 생성 계획
3. 여기까지
```

Do not auto-enter spawn.

### Spawn plan

```text
기준 split 문서 확인
→ 생성 계획 제시
→ 1회 승인
→ 순차 실행
→ split 문서 Spawned 갱신
→ 결과 보고
```

Spawn plan format:

```text
1. 기준 문서: docs/superpowers/splits/...
2. 생성 대상
   1) Cycle 1a
      - branch: feat/home-ui
      - worktree: .worktrees/feat-home-ui
      - base: origin/dev
      - session: create + start brainstorming
3. 충돌 검사
   - existing branch/worktree: none
4. 실행 순서
   - worktree/branch
   - session + brief + brainstorming start
진행할까요?
```

## Spawn Execution

### Resolve target document

Priority:

1. split document created/discussed in the current conversation
2. if unclear, list candidates and ask

Never invent a document path.

### Create one Cycle

1. Verify saved split doc exists.
2. Verify Cycle is spawnable.
3. Check branch/worktree absence.
4. Create branch + worktree from base.
5. Create Codex session with best available means:
   1. Codex native session/thread
   2. else Orca or equivalent available means
   3. else stop at worktree + manual open guidance
6. Set child session model/effort explicitly:
   - model: inherit parent/session start model
   - thinking/effort: `high` for initial brainstorm/design
7. Send full brief into the new session, including the effort schedule:
   - design: high
   - implement: low/medium
   - review: high
   - commit: low
   - PR: medium
8. Auto-start: this Cycle only, `$superpowers:brainstorming`.
9. Update split doc Spawned section.
10. Report back to main session with opened locations only.

Worktree readiness means:

```text
branch exists
worktree path exists
```

Do not run `mise` / `tuist generate` in this skill.
Environment setup belongs to the child session.

### Multi-create

Only for explicit `ready 전부` style requests.

```text
plan approval
→ sequential create
→ on failure: stop
→ keep completed
→ skip remaining
→ report partial result
```

### Partial success

If worktree succeeds and session fails:

```text
부분 성공
- worktree/branch: created
- session: failed
- brief: <paste or path>
수동으로 이 worktree에서 세션을 열고 brief로 시작하면 됩니다.
```

No rollback.

## Child Session Brief Template

Use this structure in the split document. Chat only shows a short summary.

```text
너는 이 Cycle만 담당한다.

목표:
- <one line>

범위:
- in:
  - ...
- out:
  - ...

기반 계약 / 의존:
- <Cycle 0 or none>
- <key interfaces>

작업 위치:
- base: origin/dev  (or explicit override)
- branch: Type/짧은-설명
- worktree: .worktrees/Type-짧은-설명

얇은 설계 힌트:
- ...
- ...

effort 스케줄 (model: 세션 시작 model 상속):
- design/brainstorm: high
- implement: low(기계적) / medium(통합)
- review: high
- commit: low
- PR: medium
- max/ultra 금지

워크플로:
1. 이 Cycle 범위만 유지
2. $superpowers:brainstorming 으로 설계 (high)
3. 승인 후 plan
4. 구현 (low/medium)
5. 리뷰 (high)
6. 커밋/PR은 사용자 요청 시에만 (commit low / PR medium)

Mozi hard gate:
- 커밋: `커밋해` 전에 staging/commit/push 금지 → `$mozi-commit`
- PR: `PR 초안`/`작성만`은 본문만, 생성은 `PR 생성해`/`PR 올려`/`올려` → `$mozi-pr`
- Feature → Data / Core* / ThirdPartyCore 금지
- live 조립은 App only
- Domain 계약 임의 변경 금지
- 다른 Cycle 범위 침범 금지
```

## Main Session Role After Spawn

Keep only a light registry in chat/doc:

- which Cycles are open
- worktree paths
- session ids/links if available

Do not monitor child progress or mediate unless the user asks.

## Flow

### Split

```text
기능 분해해
  → small-work guard
  → thin overall direction
  → medium survey
  → Cycle decomposition
  → briefs + branch/worktree proposals
  → 분해 초안 + 파일명 제안
  → 1회 승인
  → split 문서 저장
  → 다음 메뉴
```

### Spawn

```text
Cycle 1a 워크트리/세션 만들어
  → saved split doc resolve
  → 생성 계획
  → 1회 승인
  → worktree/branch 생성
  → session 생성 (model 상속 + high) + brief + brainstorming start
  → Spawned 갱신
  → 결과 보고
```

## Refusal / Stop Snippets

### Spawn without saved split

```text
아직 저장된 split 문서가 없습니다. 먼저 분해 저장부터 할까요?
```

### Existing branch/worktree

```text
같은 branch/worktree가 이미 있습니다. 덮어쓰지 않았습니다.
정리하거나 다른 이름을 정해 주세요.
```

### Missing spawn scope

```text
어떤 Cycle을 생성할까요?
예: Cycle 1a / ready 전부
```

### Split stage creation request

```text
지금은 분해 단계입니다. 생성은 split 문서 저장 후
`Cycle ... 워크트리/세션 만들어` 로 진행할게요.
```

### Forbidden dependency split

```text
이 분해는 Mozi 금지 의존을 넘습니다. Domain Client 계약 기준으로 다시 나눌게요.
```

## Output

### Split stage

- cycle map
- ready/PR candidate summary
- brief summaries
- proposed filename
- saved path after approval

### Spawn stage

- creation plan
- created branch/worktree
- session result or partial-success guidance
- updated Spawned section

## Non-Goals

- whole-feature deep design in main session
- automatic multi-spawn without explicit scope
- commit / PR creation
- worktree environment bootstrap beyond git
- active multi-agent orchestration from main

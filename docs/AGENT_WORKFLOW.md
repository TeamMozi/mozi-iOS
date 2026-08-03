# Agent Workflow

Mozi 작업 시 에이전트 Git/PR 하드 게이트.

기준 문서:

- [skills.md](skills.md)
- [CONVENTIONS.md](CONVENTIONS.md)
- project skills: `.codex/skills/mozi-worktree-bootstrap`, `.codex/skills/mozi-commit`, `.codex/skills/mozi-pr`

개인 취향 원본(설계실):

- `~/MySpace/Projects/dev-journal/superpowers-friction/preferences/`

## 1. Hard Gates

### worktree

1. Mozi worktree 세션에서는 ready 확인이 최우선
2. ready 가 아니면 `./scripts/setup-worktree.sh` 먼저 실행
3. ready 기준: 브랜치 checkout + `Config/Debug.xcconfig` + `Config/Release.xcconfig` + `Mozi.xcworkspace`
4. 이미 ready 면 setup 재실행 금지

worktree 진입/미준비 시 `$mozi-worktree-bootstrap` 를 사용한다.

### 커밋

1. `커밋해` 전에는 staging/commit/push 시작 금지
2. 계획 단계에서는 `git status` / `git diff` 읽기만
3. 커밋 계획(제목 + 의도 + 파일) 1회 승인 후 연속 진행
4. 커밋 메시지: `Type: 요약`, 한국어, 제목만, body 금지
5. 한 의도 = 한 커밋 (구현/테스트/문서/설정 분리)

커밋 요청 시 `$mozi-commit` 를 사용한다.

### PR

1. `PR 초안` / `초안 작성` / `작성만` = 본문 초안만
2. 위 단계에서는 commit/push/PR 생성 금지
3. 실제 생성 트리거: `PR 생성해` / `PR 올려` / `올려`
4. 생성 형태: open PR 만 (draft 해석 금지)
5. 커밋/푸시 전이면 중단하고 아래 문구 사용:

```text
아직 커밋/푸시 전입니다. 커밋해 라고 하면 커밋 계획부터 시작할게요.
```

6. PR 용 push 직전: `origin/dev` fetch 후 rebase
7. rebase 충돌 시 자동 처리 금지, 즉시 중단

PR 초안/생성 요청 시 `$mozi-pr` 를 사용한다.

## 2. Document Rules

### 커밋

- 형식: `Type: 요약`
- Type: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- 커밋 그래프만 봐도 변경 흐름이 읽혀야 함

### PR 본문

- 제목 / 변경 요약 / 변경 내용: 명사형
- 변경 요약: 3줄 전후
- 변경 내용: 모듈/영역 단위
- 기타 참고 사항: 선택 섹션, 없으면 삭제
- base/head/브랜치/커밋 해시 등 운영 메타 금지

### PR 메타

- Labels: 레포 라벨 목록 기준 **1개만**
- 애매하면 후보를 보여준 뒤 선택
- Assignees: 현재 사용자
- Reviewers/Milestone/Projects 는 명시 요청 시에만

### 언어

- 로컬 문서, 스크립트 주석/usage, 코드 주석, 에이전트 문서: 한국어 기본
- API 이름, 옵션명, 식별자는 영어 유지

## 3. Runtime Flow

### 커밋

```text
커밋해
  → 변경 확인
  → 계획 제안
  → 1회 승인
  → 연속 커밋
  → 결과 보고
```

### PR 초안

```text
PR 초안 / 작성만
  → 본문 초안 제시
  → 종료
```

### PR 생성

```text
PR 생성해 / PR 올려 / 올려
  → 커밋/푸시 상태 확인
  → push 필요 시 origin/dev rebase
  → 충돌 시 중단
  → open PR 생성 (label 1 + self assignee)
  → 결과 보고
```

## 4. Non-Goals

- 전역 Superpowers plugin 수정 없음
- 도구 경로 고정 규칙은 아직 적용하지 않음
- document rule 전부를 hard gate 로 격상하지 않음

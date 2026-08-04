# AGENTS

Mozi 작업 시 에이전트 진입점.

## 0. Worktree Hard Gate

Mozi worktree 세션에서는 **어떤 응답/작업보다 먼저** ready 여부를 확인한다.

ready 가 아니면 즉시 실행:

```bash
./scripts/setup-worktree.sh
```

ready 판정(모두 만족해야 ready):

1. detached HEAD 가 아님
2. `Config/Debug.xcconfig` 존재
3. `Config/Release.xcconfig` 존재
4. `Mozi.xcworkspace` 존재

규칙:

- ready 가 아니면 setup 없이 본 요청을 시작하지 않는다
- setup 후 한 줄로 결과(브랜치/workspace/config)를 보고한 뒤 본 요청을 처리한다
- 이미 ready 면 setup 을 다시 돌리지 않는다
- 사용자가 명시적으로 다른 옵션을 주면 그때만 `--skip-build` 등을 사용한다
- 스킬: `$mozi-worktree-bootstrap` (`.codex/skills/mozi-worktree-bootstrap`)

## 1. 프로젝트 한 줄

```text
Tuist multi-project iOS 앱
세로 계층은 모듈, 가로 Feature는 폴더
TCA + Domain Client + App live 조립
```

## 2. 문서 우선순위

1. docs/ARCHITECTURE.md
2. docs/CONVENTIONS.md
3. docs/AGENT_WORKFLOW.md
4. docs/skills.md
5. AGENTS.md
6. CLAUDE.md -> AGENTS.md

## 3. 구조

```text
Projects/
  Shared/{Util,DesignSystem,Logger}
  ThirdParty/{ThirdParty,ThirdPartyUI,ThirdPartyCore}
  Domain/
  Core/{Network,Storage}
  Data/
  Feature/
  App/
```

금지:

```text
Feature → Data / Core* / ThirdPartyCore
Domain  → Data / Core* / Feature
Data    → Feature
```

## 4. 현재 앱 흐름

```text
MoziApp → CompositionRoot → RootFeature → AppCoordinator
  bootstrapping → main(Placeholder)
```

Domain/Data 는 초기 placeholder 만 둔다.

## 5. 규칙

1. Feature 모듈 분리 금지
2. Scene 직접 참조 금지
3. live 조립 App only
4. Feature 는 Domain `*Client` 만
5. scheme: Mozi-Debug / Mozi
6. bundle: com.teamMozi.debug / com.teamMozi.app

## 6. Git / PR

- 브랜치: `Type/짧은-설명`
- 커밋: `Type: 요약`
- PR 제목: 변경 내용만
- PR 본문: `변경 요약` + 영역별 `변경 내용`
  - 템플릿: `.github/pull_request_template.md`
- 워크플로 상세: [docs/AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md)

Hard gates:

1. `커밋해` 전 staging/commit/push 금지
2. 커밋 계획 전 로컬 린트 1회: `mise exec -- swiftlint lint --strict`
3. 커밋은 계획(제목+의도+파일) 1회 승인 후 진행
4. `PR 초안` / `작성만` = 본문만, 생성 금지
5. `PR 생성해` / `PR 올려` / `올려` 전 PR 생성 금지
6. PR용 push 전 `origin/dev` rebase, 충돌 시 중단

스킬:

- worktree: `$mozi-worktree-bootstrap`
- 커밋: `$mozi-commit`
- PR: `$mozi-pr`
- 스킬 목록: [docs/skills.md](docs/skills.md)

## 7. 명령

```bash
mise install
mise exec -- tuist generate --no-open
open Mozi.xcworkspace
xcodebuild -workspace Mozi.xcworkspace -scheme Mozi-Debug -destination 'generic/platform=iOS Simulator' build
```

## 8. Worktree

상세 절차. 강제 규칙은 위 `0. Worktree Hard Gate` 를 따른다.
새 git worktree 로 작업할 때는 첫 진입 시 아래 스크립트를 실행한다.
일회성 수동 세팅이 아니라 이 경로를 기본으로 쓴다.

```bash
./scripts/setup-worktree.sh
```

스크립트가 하는 일:

1. detached HEAD 이면 로컬 브랜치 생성 또는 전환
   - `MOZI_WORKTREE_BRANCH` 가 있으면 그 이름 사용
   - 없으면 Codex worktree id 기준 `codex/<id>` (예: `codex/f8d0`)
   - 이미 브랜치에 있으면 유지
2. 다른 worktree/main 에서 `Config/Debug.xcconfig`, `Config/Release.xcconfig` 복사
3. `mise trust` + `mise install`
4. `tuist generate`
5. `Mozi-Debug` 빌드 검증 (로컬 `.derivedData`)

옵션:

- `--skip-build`: 빌드 검증 생략
- `--force-generate`: workspace 가 있어도 generate 재실행
- `MOZI_CONFIG_SOURCE=/path/to/main`: config 복사 소스 강제 지정
- `MOZI_WORKTREE_BRANCH=feat/foo`: detached HEAD 일 때 생성/전환할 브랜치 지정

참고:

- Codex worktree 세션은 기본적으로 detached HEAD 로 열린다.
- 이 스크립트가 임시 브랜치(`codex/<id>`)를 만든 뒤, 작업 주제가 정해지면 `Type/짧은-설명` 으로 rename 하거나 새로 판다.

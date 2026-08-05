# AGENTS

Mozi 작업 시 에이전트 진입점.

## 1. 프로젝트 한 줄

```text
Tuist multi-project iOS 앱
세로 계층은 모듈, 가로 Feature는 폴더
TCA + Domain Client + App live 조립
```

## 2. 문서 우선순위

1. `docs/ARCHITECTURE.md` — 전역 구조
2. `docs/CONVENTIONS.md` — 작성 규칙(주석/테스트/형식)
3. `docs/AGENT_WORKFLOW.md` — 실행/hard gate
4. `docs/skills.md` — 스킬 인덱스
5. `AGENTS.md` — 진입 요약
6. `CLAUDE.md` → `AGENTS.md`
7. `Projects/**/README.md` — 모듈 디테일

## 3. 구조 요약 + 금지 의존

```text
Projects/
  Shared/{Util,DesignSystem,Logger}
  ThirdParty/{ThirdParty,ThirdPartyUI,ThirdPartyCore}
  Domain/
  Core/{Network,Storage,SocialAuth}
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

## 5. 핵심 규칙 요약

1. Feature 모듈 분리 금지
2. Scene 직접 참조 금지
3. live 조립 App only
4. Feature 는 Domain `*Client` 만
5. scheme: `Mozi-Debug` / `Mozi`, bundle: `com.teamMozi.debug` / `com.teamMozi.app`

## 6. Git / PR Hard Gate 요약

- `커밋해` 전 staging/commit/push 금지
- 커밋 계획 전 로컬 린트 1회
- 커밋은 계획(제목+의도+파일) 1회 승인 후 진행
- `기능 분해해` = 분해/문서만, 구현·생성 금지
- `Cycle ... 워크트리/세션 만들어` 전 worktree/session 생성 금지
- `PR 초안` / `작성만` = 본문만
- `PR 생성해` / `PR 올려` / `올려` 전 PR 생성 금지
- PR용 push 전 `origin/dev` rebase, 충돌 시 중단

상세 절차: [docs/AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md)  
형식 규칙: [docs/CONVENTIONS.md](docs/CONVENTIONS.md)  
스킬: [docs/skills.md](docs/skills.md)

- 커밋: `$mozi-commit`
- 기능 분해/분기: `$mozi-feature-split`
- PR: `$mozi-pr`
- cleanup: `$mozi-worktree-cleanup`

## 7. 명령

```bash
mise install
mise exec -- tuist generate --no-open
open Mozi.xcworkspace
xcodebuild -workspace Mozi.xcworkspace -scheme Mozi-Debug -destination 'generic/platform=iOS Simulator' build
```

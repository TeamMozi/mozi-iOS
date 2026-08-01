# AGENTS

Mozi 작업 시 에이전트 진입점.

## 1. 프로젝트 한 줄

```text
Tuist multi-project iOS 앱
세로 계층은 모듈, 가로 Feature는 폴더
TCA + Domain Client + App live 조립
```

## 2. 문서 우선순위

1. docs/ARCHITECTURE.md
2. docs/CONVENTIONS.md
3. AGENTS.md
4. CLAUDE.md -> AGENTS.md

## 3. 구조

```text
Projects/
  Shared/{Util,DesignSystem}
  ThirdParty/{ThirdParty,ThirdPartyUI,ThirdPartyCore}
  Domain/
  Core/{Network,Storage,Logger}
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

## 7. 명령

```bash
mise install
mise exec -- tuist generate --no-open
open Mozi.xcworkspace
xcodebuild -workspace Mozi.xcworkspace -scheme Mozi-Debug -destination 'generic/platform=iOS Simulator' build
```

## 8. Worktree

새 git worktree 로 작업할 때는 첫 진입 시 아래 스크립트를 실행한다.
일회성 수동 세팅이 아니라 이 경로를 기본으로 쓴다.

```bash
./scripts/setup-worktree.sh
```

스크립트가 하는 일:

1. 다른 worktree/main 에서 `Config/Debug.xcconfig`, `Config/Release.xcconfig` 복사
2. `mise trust` + `mise install`
3. `tuist generate`
4. `Mozi-Debug` 빌드 검증 (로컬 `.derivedData`)

옵션:

- `--skip-build`: 빌드 검증 생략
- `--force-generate`: workspace 가 있어도 generate 재실행
- `MOZI_CONFIG_SOURCE=/path/to/main`: config 복사 소스 강제 지정

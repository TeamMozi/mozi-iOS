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

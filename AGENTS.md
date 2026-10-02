# AGENTS

Mozi 작업 시 에이전트 진입점.

---

## 어디를 보나

| 질문 | 문서 |
|---|---|
| 모듈·의존·앱 흐름 | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| 코딩·Git 규칙 | [docs/CONVENTIONS.md](docs/CONVENTIONS.md) |
| 모듈 내부 규칙·진입점 | `Projects/**/README.md` |
| 포맷·안전성 | [.swiftlint.yml](.swiftlint.yml) |
| 리뷰 기준 | [.coderabbit.yaml](.coderabbit.yaml) |
| PR 본문 | [.github/pull_request_template.md](.github/pull_request_template.md) |

---

## 절대 규칙

1. Feature 는 단일 모듈이다. 기능은 폴더로 나눈다
2. Scene 간 직접 참조를 금지한다. `delegate` 로 상위에 올린다
3. Feature 의 데이터 접근은 Domain `*Client` 만 쓴다
4. `*Client` 구현 조립은 Data 의 `*ClientFactory` 가 하고, 등록과 주입은 App 과 DemoApp 만 한다
5. 금지 의존: `Feature → Data / Core* / ThirdPartyCore`, `Domain → Data / Core* / Feature`, `Data → Feature`, `Core/* → Domain / Data / Feature / App`, `DemoApp → Data / Core* / ThirdPartyCore`
6. `AppShell`, `AppRuntime`, `AppEnvironment`, `AppConstants` 와 UseCase 층을 만들지 않는다

---

## 먼저 물을 것

- Feature 모듈 분리
- Feature → Data / Core* 직접 참조
- scheme / bundle 이름 변경
- 문서 추가·분리

---

## 자주 쓰는 명령

```bash
mise install
mise exec -- tuist generate --no-open
open Mozi.xcworkspace
xcodebuild -workspace Mozi.xcworkspace -scheme Mozi-Debug -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.4.1' build
xcodebuild -workspace Mozi.xcworkspace -scheme MoziDemo -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.4.1' build

# TestFlight 업로드 (fastlane/.env 필요). app 은 mozi(본 앱) 또는 demo(데모 앱 「모지 데모」)
mise exec -- bundle install
mise exec -- bundle exec fastlane beta app:mozi note:"이번 빌드에서 볼 것"
mise exec -- bundle exec fastlane beta app:demo note:"이번 빌드에서 볼 것"
mise exec -- bundle exec fastlane resume app:mozi build:20260923.1 note:"이번 빌드에서 볼 것 (6c004cd)"
```

# Mozi Architecture

중대형 iOS 앱 기준 아키텍처. Dulpick 구조를 모지에 스캐폴딩한 결과.

```text
세로 계층 = 모듈
가로 Feature = 폴더
외부 의존성 = ThirdParty*
기술 구현 = Core/* / 도메인 오케스트레이션 = Data / 등록 = App 과 DemoApp 만
```

---

## 1. 모듈

```text
Projects/
  Shared/{Util,DesignSystem,Logger}
  ThirdParty/{ThirdParty,ThirdPartyUI,ThirdPartyCore}
  Domain/
  Core/{Network,Storage,SocialAuth}
  Data/
  Feature/
  App/
  DemoApp/
```

| 모듈 | 책임 |
|---|---|
| SharedUtils | AppInfo, pure Foundation 헬퍼 |
| SharedDesignSystem | UI 토큰/컴포넌트 |
| SharedLogger | 전역 `Logger.shared` OSLog facade |
| ThirdParty* | 외부 패키지 진입점 |
| Domain | Entity, `*Client`, Error |
| Core/* | Network/Storage/SocialAuth 등 기술 구현. Domain 모름 |
| Data | DTO, Datasource, Mapper, `*RepositoryImpl`, `*ClientFactory`, `*SessionAssembly` (Remote는 순수 서버 통신) |
| Feature | Root, Flow, Scene |
| App | bootstrap, 의존성 주입, root store |
| DemoApp | 데모 앱 「모지 데모」. 서버 없이 화면·상태를 보는 목록, 가짜 응답, 디자인 시스템 화면(색·글자·버튼) |

`RootFeature` 는 상태가 없는 통과 계층이지만 남긴다. 앱 전체에 걸치는 상태가 생기면 둘 자리다.

### 의존

```text
Feature → Domain, SharedUtils, SharedDesignSystem, SharedLogger, ThirdParty, ThirdPartyUI
Data    → Domain, Core/*, SharedLogger, SharedUtils
Domain  → SharedUtils, ThirdParty
Core/*  → SharedUtils, SharedLogger, ThirdPartyCore
SharedLogger → SharedUtils, OSLog
App     → 조립
DemoApp → Feature, Domain, SharedDesignSystem, ThirdParty, ThirdPartyUI (가짜 응답 조립)
```

### 금지

```text
Feature → Data / Core* / ThirdPartyCore
Domain  → Data / Core* / Feature
Data    → Feature
Core/*  → Domain / Data / Feature / App
DemoApp → Data / Core* / ThirdPartyCore
```

---

## 2. 런타임

```text
MoziApp
  → CompositionRoot.makeRootStore()
      → AppBootstrap
          → InfraContainer.make()
          → Dependencies.register
              → AuthClientFactory.make(session:)
      → Store(RootFeature)
  → RootView → RootFlowView
```

앱 상태:

```text
bootstrapping
  → restoreSession()
      nil → login(LoginFeature)
      profileCompleted == false → onboarding(OnboardingFlowFeature)
      profileCompleted == true → main(MainTabFeature)
```

Auth 인프라 + 로그인 게이트 + CoreSocialAuth 기반 카카오/애플 연동이 존재한다.
App 은 SocialAuth factory 조립과 bootstrap/redirect 호출만 담당한다.

MainTab 이 탭 다섯(`shortform` / `search` / `chat` / `myPage` / `create`)을 쥔다.
탭 안에 들어갈 화면은 아직 없고 컨테이너와 자리표시 화면만 있다.
로그아웃은 마이 탭 하나에서만 나가고 MyPageFlow → MainTab → RootFlow 를 거쳐 login 으로 되돌린다.

---

## 3. App / Config

| Scheme | Config | Bundle ID | 용도 |
|---|---|---|---|
| `Mozi-Debug` | Debug | `com.teamMozi.debug` | 개발 · CI 빌드 |
| `Mozi` | Release | `com.teamMozi.app` | 아카이브 · TestFlight 업로드 (`fastlane beta`) |
| `MoziDemo` | 실행 Debug · 아카이브 Release | `com.teamMozi.demo` | 데모 앱 「모지 데모」 · TestFlight 업로드 (`fastlane beta app:demo`) |

Keychain service 는 Bundle ID 를 사용하고, UserDefaults 는 standard 를 사용한다.

TestFlight 업로드 절차는 `fastlane/Fastfile` 에 있다. 빌드 번호 `YYYYMMDD.N` 은 fastlane 이 아카이브 때 `CURRENT_PROJECT_VERSION` 으로 넣는다. 키 값은 `fastlane/.env` 에 두고 `fastlane/.env.example` 을 견본으로 쓴다. 아카이브 때 업로드 문구(해시 포함, UTF-8 → Base64)와 커밋 해시를 빌드 설정 `MOZI_BUILD_NOTE`·`MOZI_BUILD_HASH` 로 두 앱 모두에 넘긴다. 읽는 것은 데모 앱뿐이다(Info.plist `MoziBuildNote`·`MoziBuildHash`).

---

## 4. 새 기능

1. Domain `{Model,Error,Client}`
2. Data `{DTO,Datasource,Mapper,RepositoryImpl,ClientFactory,SessionAssembly}`
3. App `Dependencies.register`
4. Feature `Scene/<Name>`
5. 필요 시 Flow/Root/DeepLink
6. Feature 테스트

---

## 5. 관련

- [CONVENTIONS.md](CONVENTIONS.md)
- [../AGENTS.md](../AGENTS.md)
- [../CLAUDE.md](../CLAUDE.md)

## 모듈 디테일

전역 지도만 이 문서에 둔다. 모듈 내부 규칙/진입점/테스트 포인트는 각 README 를 본다.

- [Feature](../Projects/Feature/README.md)
- [Domain](../Projects/Domain/README.md)
- [Data](../Projects/Data/README.md)
- [CoreNetwork](../Projects/Core/Network/README.md)
- [CoreSocialAuth](../Projects/Core/SocialAuth/README.md)
- [DemoApp](../Projects/DemoApp/README.md)

---

## 지원 기기

- iPhone only
- iPad / Mac Catalyst / Apple Vision 미지원

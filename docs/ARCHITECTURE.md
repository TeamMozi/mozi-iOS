# Mozi Architecture

중대형 iOS 앱 기준 아키텍처. Dulpick 구조를 모지에 스캐폴딩한 결과.

```text
세로 계층 = 모듈
가로 Feature = 폴더
외부 의존성 = ThirdParty*
기술 구현 = Core/* / 도메인 오케스트레이션 = Data / live 등록 = App only
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
```

| 모듈 | 책임 |
|---|---|
| SharedUtils | AppInfo, pure Foundation 헬퍼 |
| SharedDesignSystem | UI 토큰/컴포넌트 |
| SharedLogger | 전역 `Logger.shared` OSLog facade |
| ThirdParty* | 외부 패키지 진입점 |
| Domain | Entity, `*Client`, Error |
| Core/* | Network/Storage/SocialAuth 등 기술 구현. Domain 모름 |
| Data | DTO, Datasource, `*RepositoryImpl`, `*ClientFactory`, `*Client.live` (Remote는 순수 서버 통신) |
| Feature | Root, AppCoordinator, Scene |
| App | bootstrap, live 주입, root store |

### 의존

```text
Feature → Domain, SharedUtils, SharedDesignSystem, SharedLogger, ThirdParty, ThirdPartyUI
Data    → Domain, Core/*, SharedLogger, SharedUtils
Domain  → SharedUtils, ThirdParty
Core/*  → SharedUtils, SharedLogger, ThirdPartyCore
SharedLogger → SharedUtils, OSLog
App     → 조립
```

### 금지

```text
Feature → Data / Core* / ThirdPartyCore
Domain  → Data / Core* / Feature
Data    → Feature
Core/*  → Domain / Data / Feature / App
```

---

## 2. 런타임

```text
MoziApp
  → CompositionRoot.makeRootStore()
      → AppBootstrap
          → InfraContainer.live()
          → Dependencies.register
              → AuthClient.live(...)
      → Store(RootFeature)
  → RootView → AppCoordinatorView
```

앱 상태:

```text
bootstrapping
  → restoreSession()
      nil → login(LoginFeature)
      profileCompleted == false → onboarding(OnboardingPlaceholderFeature)
      profileCompleted == true → main(Placeholder)
```

Auth 인프라 + 로그인 게이트 + CoreSocialAuth 기반 카카오/애플 연동이 존재한다.
App 은 SocialAuth factory 조립과 bootstrap/redirect 호출만 담당한다. MainTab 은 후속이다.

---

## 3. App / Config

| Scheme | Config | Bundle ID |
|---|---|---|
| `Mozi-Debug` | Debug | `com.teamMozi.debug` |
| `Mozi` | Release | `com.teamMozi.app` |

Keychain service 는 Bundle ID 를 사용하고, UserDefaults 는 standard 를 사용한다.

---

## 4. 새 기능

1. Domain `{Model,Error,Client}`
2. Data `{DTO,Datasource,RepositoryImpl,ClientFactory,Client.live}`
3. App `Dependencies.register`
4. Feature `Scene/<Name>`
5. 필요 시 AppCoordinator/DeepLink
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

---

## 지원 기기

- iPhone only
- iPad / Mac Catalyst / Apple Vision 미지원

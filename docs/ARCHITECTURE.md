# Mozi Architecture

중대형 iOS 앱 기준 아키텍처. Dulpick 구조를 모지에 스캐폴딩한 결과.

```text
세로 계층 = 모듈
가로 Feature = 폴더
외부 의존성 = ThirdParty*
live 조립 = App only
```

---

## 1. 모듈

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

| 모듈 | 책임 |
|---|---|
| SharedUtils | AppInfo, pure Foundation 헬퍼 |
| SharedDesignSystem | UI 토큰/컴포넌트 |
| SharedLogger | 전역 `Logger.shared` OSLog facade |
| ThirdParty* | 외부 패키지 진입점 |
| Domain | Entity, `*Client`, Error |
| Core/* | Network/Storage |
| Data | DTO, Datasource, `*RepositoryImpl`, `*ClientFactory` |
| Feature | Root, AppCoordinator, Scene |
| App | bootstrap, live 주입, root store |

### 의존

```text
Feature → Domain, SharedUtils, SharedDesignSystem, SharedLogger, ThirdParty, ThirdPartyUI
Data    → Domain, Core/*, SharedLogger, SharedUtils
Domain  → SharedUtils, ThirdParty
Core/*  → SharedUtils, ThirdPartyCore
SharedLogger → SharedUtils, OSLog
App     → 조립
```

### SharedUtils

- 포함: `AppInfo`, pure Foundation 헬퍼
- 제외: UI, Network, Storage, Logger, Domain, TCA helper

### SharedLogger

- 전역 `Logger.shared` OSLog facade
- `AppInfo.bundleID`를 subsystem으로 사용
- category별 logger 캐시는 `Locked`로 보호

### 금지

```text
Feature → Data / Core* / ThirdPartyCore
Domain  → Data / Core* / Feature
Data    → Feature
```

---

## 2. 런타임

```text
MoziApp
  → CompositionRoot.makeRootStore()
      → AppBootstrap
          → InfraContainer.live()
          → Dependencies.register
      → Store(RootFeature)
  → RootView → AppCoordinatorView
```

앱 상태(스캐폴딩):

```text
bootstrapping
  → main(Placeholder)
```

Auth / MainTab 샘플은 포함하지 않는다.

---

## 3. Feature

```text
Feature/Sources/
  Root/
  AppCoordinator/
    DeepLink/
    Overlay/
  Scene/
    Placeholder/
```

규칙:

1. Scene 안은 flat (`*Feature`, `*View`)
2. Scene 간 직접 참조 금지
3. 외부 요청은 `delegate` 로 상위 상승
4. Feature 는 Domain `*Client` 만 사용
5. 전역 전환/딥링크/overlay 는 AppCoordinator

딥링크:

```text
mozi://home
```

---

## 4. Domain / Data

초기 상태:

```text
Domain/Sources/Placeholder.swift
Data/Sources/Placeholder.swift
```

이후 패턴:

```text
Domain/<Name>/{Model,Client,Error}
Data/<Name>/{DTO,Datasource,Repository}
  *RepositoryImpl
  *ClientFactory
```

---

## 5. App / Config

| Scheme | Config | Bundle ID |
|---|---|---|
| `Mozi-Debug` | Debug | `com.teamMozi.debug` |
| `Mozi` | Release | `com.teamMozi.app` |

storage namespace 는 Bundle ID 재사용.

---

## 6. 새 기능

1. Domain `{Model,Error,Client}`
2. Data `{DTO,Datasource,RepositoryImpl,ClientFactory}`
3. App `Dependencies.register`
4. Feature `Scene/<Name>`
5. 필요 시 AppCoordinator/DeepLink
6. Feature 테스트

---

## 7. 관련

- [CONVENTIONS.md](CONVENTIONS.md)
- [../AGENTS.md](../AGENTS.md)
- [../CLAUDE.md](../CLAUDE.md)

---

## 지원 기기

- iPhone only
- iPad / Mac Catalyst / Apple Vision 미지원

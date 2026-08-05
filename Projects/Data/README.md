# Data

## 책임
- DTO, Datasource, `*RepositoryImpl`, `*ClientFactory`, Domain 오케스트레이션(`*Client.live`)

## 현재 상태
- Auth 구현
  - DTO/Endpoint/Datasource
  - `AuthLocalDatasource`
  - `AuthTokenRefresher`
  - `AuthRepositoryImpl`
  - `AuthClientFactory` (repository → Domain client adapter)
  - `AuthClient.live` (plain/refresher/authed 풀 조립)
  - `SocialAuthCredentialProvider` (`CoreSocialAuth` credential → Domain `AuthError` 매핑)

## 이후 패턴
- `Data/<Name>/{Client,DTO,Datasource,Repository,Service}`
- `*RepositoryImpl`
- `*ClientFactory` + `*Client.live`

## 의존
- 허용: Domain, Core/*, SharedLogger, SharedUtils
- 금지: Feature

## 내부 규칙
- Domain `*Client` 의 live 오케스트레이션(`*Client.live`)은 Data 에서 제공
- 기술 구현(SDK wrapper 등)은 Core/* 에 둔다
- App 은 config/factory 조립 + `prepareDependencies` 등록만 담당
- Feature 가 Data 를 직접 import 하지 않음
- refresh 는 plain client + `AuthTokenRefresher` 경로
- refresh 실패 시 unauthorized 만 로컬 세션 삭제, badRequest/일시 네트워크 오류는 세션 유지
- request body encode 는 Data remote 에서 수행하고 실패 시 throw
- 소셜 credential 은 `CoreSocialAuth` 가 담당하고, Data 는 provider 선택과 `AuthError` 매핑만 한다


## RemoteDatasource 규칙
- 순수 서버 통신만 담당
- request body encode 는 Remote 책임
- encoder 는 Remote 프로퍼티 (`NetworkJSONCoding.makeEncoder()` 기본값)
- Endpoint 는 path/method/raw body only
- response 는 공통 envelope 없이 payload DTO 직접 decode
- OAuth/SDK, 로컬 저장, Domain 매핑은 Remote 밖

## 주요 진입점
- `Sources/Auth/Client/AuthClient+Live.swift`
- `Sources/Auth/Client/AuthClientFactory.swift`
- `Sources/Auth/Repository/AuthRepositoryImpl.swift`
- `Sources/Auth/Datasource/AuthRemoteDatasource.swift`
- `Sources/Auth/Datasource/AuthLocalDatasource.swift`
- `Sources/Auth/Service/AuthTokenRefresher.swift`
- `Sources/Auth/Service/SocialAuth/SocialAuthCredentialProvider.swift`
- `Sources/Auth/Endpoint/AuthEndpoint.swift`
- `Sources/Auth/DTO/*`

## 테스트 포인트
- DTO 매핑
- local datasource 저장/삭제
- repository login/restore/logout
- token refresher rotation 교체 저장
- logout 시 로컬 세션 삭제
- factory credential → repository 연결
- SocialAuth provider 선택 / 에러 매핑
- CoreSocialAuth live 구현은 수동 검증 (SDK/UI 의존)

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)

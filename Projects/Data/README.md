# Data

## 책임
- DTO, Datasource, `*RepositoryImpl`, `*ClientFactory`, live 조립

## 현재 상태
- Auth 구현 추가
  - DTO/Endpoint/Datasource
  - `AuthLocalDatasource`
  - `AuthTokenRefresher`
  - `AuthRepositoryImpl`
  - `AuthClientFactory` (repository → Domain client adapter)
  - `AuthClient.live` (plain/refresher/authed 풀 조립)
  - `OAuthService` / `OAuthServiceFactory` (PR1 stub)

## 이후 패턴
- `Data/<Name>/{Client,DTO,Datasource,Repository,Service}`
- `*RepositoryImpl`
- `*ClientFactory` + `*Client.live`

## 의존
- 허용: Domain, Core/*, SharedLogger, SharedUtils
- 금지: Feature

## 내부 규칙
- Domain `*Client` 의 live 구현(`*Client.live`)은 Data 에서 제공
- App 은 pure infra 준비 + `prepareDependencies` 등록만 담당
- Feature 가 Data 를 직접 import 하지 않음
- refresh 는 plain client + `AuthTokenRefresher` 경로
- refresh 실패 시 unauthorized 만 로컬 세션 삭제, badRequest/일시 네트워크 오류는 세션 유지
- request body encode 는 Data remote 에서 수행하고 실패 시 throw
- OAuth credential 은 `OAuthService` 가 담당 (Souzip 스타일)

## 주요 진입점
- `Sources/Auth/Client/AuthClient+Live.swift`
- `Sources/Auth/Client/AuthClientFactory.swift`
- `Sources/Auth/Repository/AuthRepositoryImpl.swift`
- `Sources/Auth/Datasource/AuthRemoteDatasource.swift`
- `Sources/Auth/Datasource/AuthLocalDatasource.swift`
- `Sources/Auth/Service/AuthTokenRefresher.swift`
- `Sources/Auth/Service/OAuth/OAuthService.swift`
- `Sources/Auth/Service/OAuth/OAuthServiceFactory.swift`
- `Sources/Auth/Endpoint/AuthEndpoint.swift`
- `Sources/Auth/DTO/*`

## 테스트 포인트
- DTO 매핑
- local datasource 저장/삭제
- repository login/restore/logout
- token refresher rotation 교체 저장
- logout 시 로컬 세션 삭제
- factory credential → repository 연결
- OAuth stub notConfigured

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)

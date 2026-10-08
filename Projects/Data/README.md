# Data

## 책임
- DTO, Datasource, Mapper, `*RepositoryImpl`, `*ClientFactory`, Domain 오케스트레이션(`*SessionAssembly`)

## 현재 상태
- Auth 구현
  - DTO/Endpoint/Datasource
  - `AuthLocalDatasource`
  - `AuthTokenRefresher`
  - `AuthRepositoryImpl`
  - `AuthClientFactory` (조립체 → Domain client adapter)
  - `AuthSessionAssembly` (plain/refresher/authed/uploader 조립)
  - `SocialAuthCredentialProvider` (`CoreSocialAuth` credential → Domain `AuthError` 매핑)
- 공통 (`Sources/Common`)
  - `PageResponseDTO`·`PageDTOMapper`·`PageRequest.queryItems` (쪽 나눔 응답·쿼리)
  - `RemoteFailure` (서버 오류 공통 분류)
  - `UploadRemoteDatasource` (업로드 주소로 올리기)
- 오류 변환
  - `MeetingErrorMapper` (`map`, `join`)
  - `SeriesErrorMapper` (`map`)

## 이후 패턴
- `Data/<Name>/{Factory,Mapper,DTO,Datasource,Repository,Service}`
- `*RepositoryImpl`
- `*ClientFactory`. 조립체는 `AuthSessionAssembly` 하나를 같이 쓴다
- 여러 기능이 같이 쓰는 응답 꼴·변환·쿼리는 `Data/Common/{DTO,Mapper,Endpoint}` (`PageResponseDTO`, `PageDTOMapper`, `PageRequest.queryItems`)

## 의존
- 허용: Domain, Core/*, SharedLogger, SharedUtils
- 금지: Feature

## 내부 규칙
- Domain `*Client` 의 조립(`*ClientFactory`)은 Data 에서 제공
- 기술 구현(SDK wrapper 등)은 Core/* 에 둔다
- App 은 config/factory 조립 + `prepareDependencies` 등록만 담당
- Feature 가 Data 를 직접 import 하지 않음
- refresh 는 plain client + `AuthTokenRefresher` 경로
- refresh 실패 시 unauthorized 만 로컬 세션 삭제, badRequest/일시 네트워크 오류는 세션 유지
- 소셜 credential 은 `CoreSocialAuth` 가 담당하고, Data 는 provider 선택과 `AuthError` 매핑만 한다


## RemoteDatasource 규칙
- 순수 서버 통신만 담당
- request body encode 는 Remote 가 한다. 실패하면 그대로 던진다
- encoder 는 Remote 프로퍼티 (`NetworkJSONCoding.makeEncoder()` 기본값)
- Endpoint 는 path·method·headers·queryItems·body 만 정한다
- response 는 공통 envelope 없이 payload DTO 직접 decode
- OAuth/SDK, 로컬 저장, Domain 매핑은 Remote 밖

### 받는 클라이언트
- 새 Remote 는 `init(authedClient:encoder:)` 로 authed 클라이언트 하나만 받는다
- plain 클라이언트는 Auth Remote 만 받는다
- 토큰 없이 부르는 API 는 로그인 셋과 갱신 하나뿐이다
- 기능 `*ClientFactory` 는 `AuthSessionAssembly` 를 받는다
- 그 안의 `authedClient`·`uploader` 를 꺼내 Remote 에 넣는다
- 기능마다 Network 클라이언트나 조립체를 만들지 않는다
- 조립체가 둘이면 토큰 재발급이 둘로 갈린다

### 오류 변환 위치
- Remote 는 `NetworkError`·`UploadError` 를 그대로 던진다
- `*RepositoryImpl` 의 catch 가 `<기능>ErrorMapper` 를 부른다
- `<기능>ErrorMapper` 는 `RemoteFailure(error)` 를 switch 해 Domain 오류로 바꾼다
- `map` 은 이미 그 기능의 Domain 오류면 그대로 돌려준다. do 블록 안에서 던진 오류를 덮어쓰지 않기 위해서다
- 엔드포인트 예외는 동작별 함수가 먼저 거른다 (`MeetingErrorMapper.join`)
- 동작별 함수는 나머지를 공통 `map` 에 넘긴다
- 400 은 엔드포인트와 상관없이 `invalid` → Domain `validation` 이다
- 업로드 거부(`UploadError.rejected`)는 상태 코드와 상관없이 `unknown` 이다
- 엔드포인트별 오류 뜻은 `docs/agent/api/error-codes.md` 에 모은다

### 서버 message
- 서버 문구가 없으면 Domain 오류의 message 는 `""` 다
- 기술 문구(`String(describing:)`, 상태 코드)는 message 에 넣지 않는다
- 화면은 message 를 띄우지 않는다. Feature 공통 오류 문구 표(`FeatureErrorMessage`)가 오류 종류마다 문구를 주고, message 는 로그에만 남는다

### 업로드 담당 층
- 올리기는 `UploadRemoteDatasource.upload(_:to:contentType:onProgress:)` 가 맡는다
- 업로더는 `AuthSessionAssembly` 의 `uploader` 를 넣는다
- 주소 발급과 완료 통보는 기능 Remote 가 한다
- 발급 → 올리기 → 통보 순서는 기능 `*RepositoryImpl` 이 정한다

### 공개 범위
- public 은 `*ClientFactory`·`*SessionAssembly` 둘뿐이다
- Remote·DTO·Mapper·`*RepositoryImpl`·Service 는 internal 이다
- 테스트는 `@testable import Data` 로 internal 을 읽는다

### Auth 예외
- Auth 는 공통 분류(`RemoteFailure`)의 예외다
- 로그인 경로는 `AuthErrorMapper` 가 따로 바꾼다
- 갱신 경로는 `AuthTokenRefresher` 가 따로 바꾼다
- 갱신 경로는 앱 전체 로그아웃과 이어져 그대로 둔다

## 주요 진입점
- `Sources/Auth/Factory/AuthSessionAssembly.swift`
- `Sources/Auth/Factory/AuthClientFactory.swift`
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

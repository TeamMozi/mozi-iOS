# CoreNetwork

## 책임
- HTTP 요청 파이프라인, endpoint 모델, 네트워크 에러, 인증 토큰 refresh 유틸, 업로드 주소로 바이트 올리기

## 의존
- 허용: SharedUtils, SharedLogger, ThirdPartyCore
- 금지: Domain/Feature service-specific flow

## 내부 규칙
- SharedLogger category: `.network`
- service-specific domain flow 금지
- 밖에서는 `NetworkConfiguration` 과 `NetworkFactory` 로만 만든다. 구현 타입 `DefaultNetworkClient`·`DefaultUploader` 는 `internal`
- App 은 `NetworkConfiguration` 만 넘기고, Data 가 `NetworkFactory` 를 부른다. 인증 클라이언트에 Data 의 토큰 제공자·재발급기가 들어가고, 재발급 경로가 인증 없는 클라이언트를 같이 쓰기 때문이다
- factory 에 세션 인자는 없다. 테스트는 `@testable import CoreNetwork` 로 구현 타입에 스텁 세션을 넣는다
- authed 요청의 401 refresh 는 single-flight
- refresh 성공 후 generation 이 바뀌었으면 중복 refresh 없이 재시도
- 업로드는 `NetworkFactory.makeUploader()` 가 만든 `Uploading` 이 맡는다. 받은 주소 그대로 `PUT`, 리디렉션을 따라가지 않음(3xx 는 `rejected`), `Authorization`·refresh 없음, 실패는 `UploadError`(`NetworkError` 아님), 로그에 바디·주소 쿼리 없음

## 주요 진입점
- `NetworkFactory` — `makePlain(config:)`, `makeAuthed(config:tokenProvider:tokenRefresher:)`, `makeUploader()`
- `NetworkConfiguration` / `NetworkJSONCoding`
- `NetworkClient` / `APIEndpoint` / `HTTPMethod`
- `NetworkError`
- token provider/refresher 포트 (`TokenProviding` / `TokenRefreshing`)
- `Uploading` / `UploadError`

## 테스트 포인트
- factory 가 만든 클라이언트·업로더 (설정의 주소, `Authorization` 유무, `PUT`)
- request building (메서드·경로·쿼리·헤더·바디)
- 401 refresh/retry/single-flight
- error mapping (상태 코드 → `NetworkError`, 망 오류 → `transport`, 해석 실패 → `decodingFailed`)
- URL sanitize logging
- upload request (PUT·받은 주소·Content-Type·바디·Authorization 없음)와 상태 코드 → `UploadError`
- upload progress 계산 (`UploadProgressDelegate` 를 직접 호출)
- upload 로그의 주소 쿼리 제거

## 관련 문서
- [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../../docs/CONVENTIONS.md)

# CoreNetwork

## 책임
- HTTP 요청 파이프라인, endpoint 모델, 네트워크 에러, 인증 토큰 refresh 유틸, 업로드 주소로 바이트 올리기

## 의존
- 허용: SharedUtils, SharedLogger, ThirdPartyCore
- 금지: Domain/Feature service-specific flow

## 내부 규칙
- SharedLogger category: `.network`
- service-specific domain flow 금지
- authed 요청의 401 refresh 는 single-flight
- refresh 성공 후 generation 이 바뀌었으면 중복 refresh 없이 재시도
- 업로드는 `DefaultUploader` 가 맡는다. 받은 주소 그대로 `PUT`, `Authorization`·refresh 없음, 실패는 `UploadError`(`NetworkError` 아님), 로그에 바디·주소 쿼리 없음

## 주요 진입점
- `DefaultNetworkClient`
- `APIEndpoint`
- `NetworkError`
- token provider/refresher 포트
- `Uploading` / `DefaultUploader` / `UploadError`

## 테스트 포인트
- request building
- 401 refresh/retry/single-flight
- error mapping
- URL sanitize logging
- upload request (PUT·받은 주소·Content-Type·바디·Authorization 없음)와 상태 코드 → `UploadError`
- upload progress 계산 (`UploadProgressDelegate` 를 직접 호출)
- upload 로그의 주소 쿼리 제거

## 관련 문서
- [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../../docs/CONVENTIONS.md)

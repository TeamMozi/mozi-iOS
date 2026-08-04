# CoreNetwork

## 책임
- HTTP 요청 파이프라인, endpoint 모델, 네트워크 에러, 인증 토큰 refresh 유틸

## 의존
- 허용: SharedUtils, SharedLogger, ThirdPartyCore
- 금지: Domain/Feature service-specific flow

## 내부 규칙
- SharedLogger category: `.network`
- service-specific domain flow 금지
- authed 요청의 401 refresh 는 single-flight
- refresh 성공 후 generation 이 바뀌었으면 중복 refresh 없이 재시도

## 주요 진입점
- `DefaultNetworkClient`
- `APIEndpoint`
- `NetworkError`
- token provider/refresher 포트

## 테스트 포인트
- request building
- 401 refresh/retry/single-flight
- error mapping
- URL sanitize logging

## 관련 문서
- [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../../docs/CONVENTIONS.md)

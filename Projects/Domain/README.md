# Domain

## 책임
- Entity, Error, Domain port (`*Client`)

## 현재 상태
- Auth 포트 추가 (`AuthSession`, `AuthError`, `AuthProvider`, `AuthClient`)

## 이후 패턴
- `Domain/<Name>/{Model,Client,Error}`

## 의존
- 허용: SharedUtils, ThirdParty
- 금지: Data, Core*, Feature

## 내부 규칙
- 포트 이름은 `*Client`
- Domain Client 는 `@DependencyClient` 매크로 사용
- Feature 가 의존하는 유일한 도메인 경계
- UseCase 층 없음

## 주요 진입점
- `Sources/Auth/AuthClient.swift`
- `Sources/Auth/AuthSession.swift`
- `Sources/Auth/AuthError.swift`
- `Sources/Auth/AuthProvider.swift`

## 테스트 포인트
- 세션 동등성/Codable 왕복
- `AuthClient.testValue` 기본 unimplemented 동작 (`@DependencyClient`)

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)

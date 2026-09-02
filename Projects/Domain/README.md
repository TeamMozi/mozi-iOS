# Domain

## 책임
- Entity, Error, Domain port (`*Client`)

## 현재 상태
- Auth 포트 추가 (`AuthSession`, `AuthError`, `AuthProvider`, `AuthClient`)
- User 포트 추가 (`UserProfile`, `OnboardingDraft`, `Gender`, `Interest`, `UserError`, `UserClient`)

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
- `Sources/Auth/Client/AuthClient.swift`
- `Sources/Auth/Model/AuthSession.swift`
- `Sources/Auth/Model/AuthProvider.swift`
- `Sources/Auth/Error/AuthError.swift`
- `Sources/User/Client/UserClient.swift`
- `Sources/User/Model/UserProfile.swift`
- `Sources/User/Model/OnboardingDraft.swift`
- `Sources/User/Model/Gender.swift`
- `Sources/User/Model/Interest.swift`
- `Sources/User/Error/UserError.swift`

## 테스트 포인트
- 세션 동등성/Codable 왕복
- `AuthClient.testValue` 생성 가능성
- User model 동등성/Codable 왕복
- `UserClient.testValue` 생성 가능성

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)

# CoreSocialAuth

## 책임
- 소셜 identity provider credential 획득 (Kakao access token, Apple identity token)
- configuration / factory / bootstrap / redirect helper

## 금지
- Domain import
- repository / endpoint / AuthError
- App lifecycle 소유

## 의존
- 허용: ThirdPartyCore, SharedLogger, AuthenticationServices/UIKit
- 금지: Domain, Data, Feature, App

## 내부 규칙
- 밖에서는 `SocialAuthConfiguration` 과 `SocialAuthFactory` 로만 만든다. `KakaoSocialAuthService`·`AppleSocialAuthService`·`NotConfiguredSocialAuthService` 는 `internal`
- 설정·`SocialAuthBootstrap`·`SocialAuthRedirectHandler` 는 `Sources/Config/`, factory 는 `Sources/Factory/`
- factory 가 만든 서비스는 생성 시점에 SDK 를 부르지 않는다. App 은 factory 를 먼저, `SocialAuthBootstrap.run(config:)` 을 뒤에 부른다
- 카카오 키가 없거나 비면 Bootstrap 은 SDK 초기화를 건너뛰고(로그 category `.app`), factory 는 카카오 자리에 `notConfigured` 를 던지는 서비스를 넣는다
- 카카오 키 Debug 검사(`preconditionFailure`)는 App `InfraContainer.make()` 가 한다

## 주요 진입점
- `SocialAuthFactory.make(config:)`
- `SocialAuthConfiguration` / `SocialAuthServices` / `SocialAuthService` / `SocialAuthError`
- `SocialAuthBootstrap.run(config:)`
- `SocialAuthRedirectHandler.handle(url:)`

## 테스트 포인트
- factory notConfigured (kakao key 없음/빈 값)
- factory 가 키가 있으면 SDK 초기화 없이 카카오·애플 서비스를 만든다
- 테스트는 `@testable import CoreSocialAuth`
- 실제 로그인은 수동 검증 (SDK/UI 의존)

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

## 주요 진입점
- `SocialAuthServiceFactory`
- `SocialAuthConfiguration` / `SocialAuthServices` / `SocialAuthService`
- `KakaoAuthBootstrap`
- `KakaoAuthRedirectHandler`
- `KakaoSocialAuthService` / `AppleSocialAuthService`

## 테스트 포인트
- factory notConfigured (kakao key 없음/빈 값)

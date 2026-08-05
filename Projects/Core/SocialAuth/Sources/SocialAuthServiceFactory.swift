import Foundation

public struct SocialAuthServiceFactory: Sendable {
    public init() {}

    @MainActor
    public func make(configuration: SocialAuthConfiguration) -> SocialAuthServices {
        let kakao: any SocialAuthService
        if let key = configuration.kakaoAppKey, key.isEmpty == false {
            kakao = KakaoSocialAuthService()
        } else {
            kakao = NotConfiguredSocialAuthService(
                message: "Kakao login is not configured yet"
            )
        }

        return SocialAuthServices(
            kakao: kakao,
            apple: AppleSocialAuthService()
        )
    }
}

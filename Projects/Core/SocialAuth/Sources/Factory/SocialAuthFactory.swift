import Foundation

/// CoreSocialAuth 의 유일한 생성 창구. 만든 서비스는 생성 시점에 SDK 를 부르지 않는다.
public enum SocialAuthFactory {
    @MainActor
    public static func make(config: SocialAuthConfiguration) -> SocialAuthServices {
        let kakao: any SocialAuthService
        if let key = config.kakaoAppKey, key.isEmpty == false {
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

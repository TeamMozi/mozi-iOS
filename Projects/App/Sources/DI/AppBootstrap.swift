import CoreSocialAuth
import Foundation
import SharedDesignSystem
import SharedLogger
import ThirdParty

enum AppBootstrap {
    @MainActor
    static func run() {
        _ = DesignSystemFontRegistration.registerIfNeeded()
        let infra = InfraContainer.live()
        let kakaoAppKey = requireKakaoNativeAppKeyIfNeeded(
            infra.configuration.kakaoNativeAppKey
        )
        let socialConfig = SocialAuthConfiguration(
            kakaoAppKey: kakaoAppKey
        )
        KakaoAuthBootstrap.initializeIfNeeded(appKey: socialConfig.kakaoAppKey)
        prepareDependencies {
            Dependencies.register(&$0, infra: infra, socialConfig: socialConfig)
        }
        Logger.shared.info("App bootstrap completed", category: .general)
    }

    /// Debug 에서는 카카오 키 누락을 부트 시점에 즉시 실패시킨다.
    private static func requireKakaoNativeAppKeyIfNeeded(_ key: String?) -> String? {
        #if DEBUG
        guard let key, key.isEmpty == false else {
            preconditionFailure(
                """
                Missing KAKAO_NATIVE_APP_KEY.
                Copy Config/Example.xcconfig to Config/Debug.xcconfig and set the native app key for this scheme.
                """
            )
        }
        return key
        #else
        return key
        #endif
    }
}

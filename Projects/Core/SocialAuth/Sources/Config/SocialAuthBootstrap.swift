import Foundation
import SharedLogger
import ThirdPartyCore

/// 외부 SDK 초기화. App 이 factory 를 부른 뒤에 부른다.
public enum SocialAuthBootstrap {
    @MainActor
    public static func run(config: SocialAuthConfiguration) {
        guard let appKey = config.kakaoAppKey, appKey.isEmpty == false else {
            Logger.shared.info(
                "Kakao SDK skipped: KAKAO_NATIVE_APP_KEY is empty",
                category: .general
            )
            return
        }
        KakaoSDK.initSDK(appKey: appKey)
    }
}

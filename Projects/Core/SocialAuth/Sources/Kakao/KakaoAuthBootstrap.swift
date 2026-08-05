import Foundation
import SharedLogger
import ThirdPartyCore

public enum KakaoAuthBootstrap {
    @MainActor
    public static func initializeIfNeeded(appKey: String?) {
        guard let appKey, appKey.isEmpty == false else {
            Logger.shared.info(
                "Kakao SDK skipped: KAKAO_NATIVE_APP_KEY is empty",
                category: .general
            )
            return
        }
        KakaoSDK.initSDK(appKey: appKey)
    }
}

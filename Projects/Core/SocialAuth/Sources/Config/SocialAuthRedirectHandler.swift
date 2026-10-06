import Foundation
import ThirdPartyCore

/// 소셜 로그인 앱에서 돌아온 URL 을 처리한다. 처리했으면 true 다.
public enum SocialAuthRedirectHandler {
    @MainActor
    @discardableResult
    public static func handle(url: URL) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
}

import Domain
import Foundation
import ThirdParty

/// 로그인 데모 상태별 가짜 `AuthClient`. 서버와 카카오 SDK 없이 LoginFeature 를 움직인다.
public enum LoginDemoAuthClient {
    public static func make(
        for state: LoginDemoState,
        clock: any Clock<Duration> = ContinuousClock()
    ) -> AuthClient {
        AuthClient(
            restoreSession: { nil },
            login: { _ in
                switch state {
                case .idle:
                    // 1초 불러온 뒤 취소로 끝낸다. LoginFeature 는 취소를 알림 없이 원래 화면으로 돌린다.
                    try await clock.sleep(for: .seconds(1))
                    throw AuthError.cancelled
                case .loading:
                    return try await Task<AuthSession, Never>.never()
                case .networkError:
                    throw AuthError.network
                }
            },
            logout: {},
            currentSession: { nil }
        )
    }
}

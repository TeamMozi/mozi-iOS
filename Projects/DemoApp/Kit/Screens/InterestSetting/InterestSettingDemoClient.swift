import Domain
import Foundation
import ThirdParty

/// 카테고리 설정 데모 상태별 가짜 Client. 서버 없이 InterestSettingFeature 를 움직인다.
public enum InterestSettingDemoClient {
    public static func interestClient(for state: InterestSettingDemoState) -> InterestClient {
        switch state {
        case .loading:
            InterestClient(interests: { try await Task<[Interest], Never>.never() })
        case .loadFailed:
            InterestClient(interests: { throw InterestError.network })
        case .idle, .selected, .saving, .saveFailed:
            .previewValue
        }
    }

    public static func userClient(for state: InterestSettingDemoState) -> UserClient {
        switch state {
        case .saving:
            UserClient(completeOnboarding: { _ in try await Task<Void, Never>.never() })
        case .saveFailed:
            UserClient(completeOnboarding: { _ in throw UserError.network })
        case .loading, .idle, .selected, .loadFailed:
            .previewValue
        }
    }
}

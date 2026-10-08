import Domain

/// 온보딩 흐름 전체 데모 상태. 프로필부터 「완료」 까지 넘긴다.
public enum OnboardingFlowDemoState: String, CaseIterable, Hashable, Sendable {
    case start

    /// 상태 시트의 줄 이름.
    public var title: String {
        switch self {
        case .start: "처음부터"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        switch self {
        case .start: "처음"
        }
    }

    /// 흐름 데모의 가짜 `AuthClient`. 프로필 뒤로(로그아웃)는 바로 성공한다.
    public static let authClient = AuthClient(
        restoreSession: { nil },
        login: { _ in throw AuthError.cancelled },
        logout: {},
        currentSession: { nil }
    )
}

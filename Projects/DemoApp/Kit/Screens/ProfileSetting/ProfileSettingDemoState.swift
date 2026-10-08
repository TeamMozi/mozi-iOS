import Domain
import Feature
import SharedDesignSystem

/// 프로필 설정 화면 데모 상태 셋. 데모에는 온보딩 Flow 가 없어 뒤로는 아무 일도 없다.
public enum ProfileSettingDemoState: String, CaseIterable, Hashable, Sendable {
    case empty
    case filled
    case logoutFailed

    /// 상태 시트의 줄 이름.
    public var title: String {
        switch self {
        case .empty: "빈 화면"
        case .filled: "다 채운 화면"
        case .logoutFailed: "로그아웃 실패"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        switch self {
        case .empty: "빈"
        case .filled: "채움"
        case .logoutFailed: "실패"
        }
    }

    /// 이 상태로 시작하는 프로필 화면 상태. 로그아웃 실패는 알림이 떠 있는 채로 시작한다.
    public var profileState: ProfileSettingFeature.State {
        switch self {
        case .empty:
            ProfileSettingFeature.State()
        case .filled:
            ProfileSettingFeature.State(
                nickname: "수연",
                birthYear: 2000,
                birthMonth: 1,
                birthDay: 1,
                gender: .female,
                introduction: "영화 보고 노래 부르는 걸 좋아해요"
            )
        case .logoutFailed:
            ProfileSettingFeature.State(
                screen: .actionFailed(message: FeatureErrorMessage.logoutFailure(for: .storage(message: "")))
            )
        }
    }
}

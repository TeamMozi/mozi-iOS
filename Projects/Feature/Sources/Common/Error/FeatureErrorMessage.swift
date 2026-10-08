import Domain

/// Domain 오류 종류마다 화면에 띄울 문구 한 벌. 동작 이름이 필요한 화면만 몇 종류를 덮어쓴다.
/// 서버 message 는 화면에 띄우지 않는다. 오류 값째 로그에만 남는다.
public enum FeatureErrorMessage {
    static let network = "네트워크 연결을 확인해 주세요"
    static let unauthorized = "로그인이 필요해요. 다시 로그인해 주세요."
    static let unknown = "알 수 없는 오류가 발생했어요."

    /// `nil` 이면 알림 창을 띄우지 않는다(`cancelled`).
    public static func message(for error: AuthError) -> String? {
        switch error {
        case .cancelled: nil
        case .notConfigured: "로그인 설정이 완료되지 않았어요."
        case .loginFailed: "로그인에 실패했어요"
        case .network: network
        case .unauthorized: unauthorized
        case .storage: "정보를 기기에 저장하지 못했어요. 다시 시도해 주세요."
        case .unknown: unknown
        }
    }

    public static func message(for error: UserError) -> String {
        switch error {
        case .network: network
        case .unauthorized: unauthorized
        case .forbidden, .conflict: "요청을 처리하지 못했어요. 다시 시도해 주세요."
        case .notFound: "선택한 항목을 찾을 수 없어요. 다시 시도해 주세요."
        case .validation: "입력한 내용을 확인해 주세요."
        case .unknown: unknown
        }
    }

    public static func message(for error: InterestError) -> String {
        switch error {
        case .network: network
        case .unauthorized: unauthorized
        case .unknown: unknown
        }
    }

    /// 로그아웃 실패 덮어쓰기. 마이페이지 로그아웃과 온보딩 프로필 뒤로(로그아웃)가 같이 쓴다.
    public static func logoutFailure(for error: AuthError) -> String {
        switch error {
        case .storage:
            "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요."
        case .network:
            network
        case .cancelled, .notConfigured, .loginFailed, .unauthorized, .unknown:
            "로그아웃에 실패했어요. 다시 시도해 주세요."
        }
    }
}

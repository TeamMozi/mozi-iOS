import Domain

/// Domain 오류 종류마다 화면에 띄울 문구 한 벌. 동작 이름이 필요한 화면만 몇 종류를 덮어쓴다.
/// 서버 message 는 화면에 띄우지 않는다. 오류 값째 로그에만 남는다.
public enum FeatureErrorMessage {
    static let network = "네트워크 연결을 확인해 주세요"
    static let unauthorized = "로그인이 필요해요. 다시 로그인해 주세요."
    static let unknown = "알 수 없는 오류가 발생했어요."
    static let requestFailed = "요청을 처리하지 못했어요. 다시 시도해 주세요."
    static let notFound = "선택한 항목을 찾을 수 없어요. 다시 시도해 주세요."
    static let validation = "입력한 내용을 확인해 주세요."

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
        case .forbidden, .conflict: requestFailed
        case .notFound: notFound
        case .validation: validation
        case .unknown: unknown
        }
    }

    public static func message(for error: SeriesError) -> String {
        switch error {
        case .network: network
        case .unauthorized: unauthorized
        case .forbidden, .conflict: requestFailed
        case .notFound: notFound
        case .validation: validation
        case .unknown: unknown
        }
    }

    public static func message(for error: PlaceError) -> String {
        switch error {
        case .network: network
        case .unauthorized: unauthorized
        case .forbidden, .conflict: requestFailed
        case .notFound: notFound
        case .validation: validation
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

    public static func message(for error: MeetingError) -> String {
        switch error {
        case .network: network
        case .unauthorized: unauthorized
        case .forbidden, .notFound, .conflict, .validation: requestFailed
        case .joinRestricted: "참여 조건이 맞지 않아 신청할 수 없어요"
        case .unknown: unknown
        }
    }

    public static func message(for error: SnapPointError) -> String {
        switch error {
        case .network: network
        case .unauthorized: unauthorized
        case .forbidden, .notFound, .validation: requestFailed
        case .limitExceeded: "스냅 포인트는 \(SnapPointLimit.maxCount)개까지 등록할 수 있어요"
        case .sentSnapPointNotDeletable: "알림을 보낸 스냅 포인트는 삭제할 수 없어요"
        case .meetingEnded: "종료된 모임은 스냅 포인트를 바꿀 수 없어요"
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

    /// 모임 동작 실패 덮어쓰기. 모임 상세·모임 관리·멤버 관리·위젯 화면이 같이 쓴다.
    /// 네트워크·로그인·참여 조건은 표 문구를, 종류만으로 뜻이 없는 나머지는 동작 문구를 띄운다.
    /// - Parameters:
    ///   - action: 동작 문구(`MeetingAction`)
    ///   - conflict: 충돌(정원 참 등)에 따로 띄울 문구. 없으면 `action` 이다
    static func meetingFailure(for error: MeetingError, action: String, conflict: String? = nil) -> String {
        switch error {
        case .network, .unauthorized, .joinRestricted:
            message(for: error)
        case .conflict:
            conflict ?? action
        case .forbidden, .notFound, .validation, .unknown:
            action
        }
    }

    /// 스냅 포인트 동작 실패 덮어쓰기. 스냅 포인트 설정의 목록 읽기가 쓴다.
    /// 네트워크·로그인과 스냅 포인트 규칙(개수·보낸 알림·종료된 모임)은 표 문구를, 종류만으로 뜻이 없는 나머지는 동작 문구를 띄운다.
    /// - Parameter action: 동작 문구(`MeetingAction`)
    static func snapPointFailure(for error: SnapPointError, action: String) -> String {
        switch error {
        case .network, .unauthorized, .limitExceeded, .sentSnapPointNotDeletable, .meetingEnded:
            message(for: error)
        case .forbidden, .notFound, .validation, .unknown:
            action
        }
    }

    /// 모임 화면의 동작 문구. 시안에 없는 임시 문구다.
    enum MeetingAction {
        static let loadFailed = "모임을 불러오지 못했어요"
        static let membersLoadFailed = "멤버를 불러오지 못했어요"
        static let snapPointsLoadFailed = "스냅 포인트를 불러오지 못했어요"
        static let joinFailed = "참여 신청을 하지 못했어요"
        static let leaveFailed = requestFailed
        static let notificationFailed = "알림 요청을 바꾸지 못했어요"
        static let approveFailed = "승인하지 못했어요"
        static let approveCapacityFull = "정원이 다 차서 승인할 수 없어요"
        static let reopenCapacityFull = "정원이 다 차서 모집을 다시 열 수 없어요"
        static let kickFailed = "내보내지 못했어요"
        static let deleteFailed = "모임을 삭제하지 못했어요"

        static func statusChangeFailed(_ status: MeetingStatus) -> String {
            switch status {
            case .recruiting: "모집을 다시 열지 못했어요"
            case .closed: "모집을 마감하지 못했어요"
            case .ended: "모임을 종료하지 못했어요"
            }
        }
    }
}

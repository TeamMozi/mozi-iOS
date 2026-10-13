import Domain

/// 위젯 데모 상태 둘. 앞의 몇 개에 알림을 보낸 채로 시작한다. 둘 다 모집 마감으로 시작한다.
public enum MeetingWidgetDemoState: String, CaseIterable, Hashable, Sendable {
    case beforeNotification
    case inProgress

    /// 상태 시트의 줄 이름.
    public var title: String {
        switch self {
        case .beforeNotification: "알림 전"
        case .inProgress: "진행 중"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        title
    }

    /// 처음부터 알림을 보낸 스냅 포인트 수
    public var sentSnapPointCount: Int {
        switch self {
        case .beforeNotification: 0
        case .inProgress: 2
        }
    }

    /// 처음 모임 상태. 위젯은 진행 중인 모임에서 뜨므로 모집 마감으로 시작한다(모집 중이면 「모임 종료」 가 감춰진다)
    public var initialMeetingStatus: MeetingStatus {
        .closed
    }
}

/// 모임 상세 데모 관점 넷. 고른 관점의 「나」 로 같은 가짜 모임을 본다.
public enum MeetingDetailDemoState: String, CaseIterable, Hashable, Sendable {
    case host
    case member
    case pending
    /// 신청 전. `none` 은 옵셔널과 헷갈려 쓰지 않는다
    case applicant

    /// 상태 시트의 줄 이름.
    public var title: String {
        switch self {
        case .host: "모임장"
        case .member: "멤버"
        case .pending: "승인 대기"
        case .applicant: "신청 전"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        switch self {
        case .host: "모임장"
        case .member: "멤버"
        case .pending: "대기"
        case .applicant: "신청 전"
        }
    }
}

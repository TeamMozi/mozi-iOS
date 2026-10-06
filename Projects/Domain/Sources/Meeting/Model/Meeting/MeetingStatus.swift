/// 모임 상태. 「진행중」 표시는 이 값이 아니라 필름 화면이 정한다.
public enum MeetingStatus: Equatable, Hashable, Sendable {
    /// 모집 중
    case recruiting
    /// 모집 마감
    case closed
    /// 종료
    case ended
}

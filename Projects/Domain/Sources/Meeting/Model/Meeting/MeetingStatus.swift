/// 모임 상태. 「진행중」 표시는 이 값이 아니라 필름 화면이 정한다.
public enum MeetingStatus: Equatable, Hashable, Sendable {
    /// 모집 중
    case recruiting
    /// 모집 마감
    case closed
    /// 종료
    case ended
}

extension MeetingStatus {
    /// 이 상태에서 종료로 넘길 수 있는지. 모집 마감에서만 된다.
    /// 모집 중은 모집 마감을 거쳐야 하고(서버 409), 종료된 모임은 이미 끝났다.
    public var canEnd: Bool {
        self == .closed
    }
}

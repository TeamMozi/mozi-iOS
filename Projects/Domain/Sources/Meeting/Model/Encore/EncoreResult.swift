/// 앵콜 모임 만들기 결과.
public enum EncoreResult: Equatable, Sendable {
    /// 모임과 시리즈가 모두 생겼다
    case created(Meeting, Series)
    /// 모임은 생겼고 시리즈 만들기만 실패했다
    case meetingOnly(Meeting, SeriesError)
}

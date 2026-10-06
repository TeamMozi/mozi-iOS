/// 모임을 보는 나의 참여 상태. 서버에 아직 없다.
/// 서버가 줄 때까지 Data 는 모임장 id 와 로그인 사용자 id 가 같으면 `.host` 를, 그 밖에는 `.none` 을 돌려준다.
public enum MyParticipation: Equatable, Hashable, Sendable {
    /// 모임장
    case host
    /// 멤버
    case member
    /// 승인 대기
    case pending
    /// 신청 전
    case none
}

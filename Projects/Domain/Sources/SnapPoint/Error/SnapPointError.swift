/// 서버에 스냅 포인트 API 가 아직 없다. 서버 문구가 없으면 message 는 `""` 다.
public enum SnapPointError: Error, Equatable, Sendable {
    case network
    case unauthorized
    case forbidden
    case notFound
    /// 모임마다 `SnapPointLimit.maxCount` 개를 넘었다
    case limitExceeded
    /// 촬영 알림을 보낸 스냅 포인트는 지우지 않는다
    case sentSnapPointNotDeletable
    /// 종료된 모임의 스냅 포인트는 바꾸지 않는다
    case meetingEnded
    case validation(message: String)
    case unknown(message: String)
}

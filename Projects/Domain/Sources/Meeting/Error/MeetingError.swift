/// 서버는 `{ "message": "..." }` 와 상태 코드만 준다. 409 의 세부 사유는 `conflict(message:)` 로 넘긴다.
public enum MeetingError: Error, Equatable, Sendable {
    case network
    case unauthorized
    case forbidden
    case notFound
    /// 정원 초과 등 상태 충돌
    case conflict(message: String)
    /// 연령·성별 등 참여 조건 미달
    case joinRestricted
    case validation(message: String)
    case unknown(message: String)
}

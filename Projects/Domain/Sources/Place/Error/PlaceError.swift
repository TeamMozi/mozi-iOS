/// 서버는 `{ "message": "..." }` 와 상태 코드만 준다. 409 의 세부 사유는 `conflict(message:)` 로 넘긴다.
public enum PlaceError: Error, Equatable, Sendable {
    case network
    case unauthorized
    case forbidden
    case notFound
    case conflict(message: String)
    case validation(message: String)
    case unknown(message: String)
}

/// 서버는 `{ "message": "..." }` 와 상태 코드만 준다. message 는 화면에 띄우지 않고 로그에만 남는다.
public enum InterestError: Error, Equatable, Sendable {
    case network
    case unauthorized
    case unknown(message: String)
}

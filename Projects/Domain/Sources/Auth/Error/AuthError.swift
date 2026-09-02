public enum AuthError: Error, Equatable, Sendable {
    case cancelled
    case notConfigured(message: String)
    case loginFailed
    case network
    case unauthorized
    case storage(message: String)
    case unknown(message: String)
}

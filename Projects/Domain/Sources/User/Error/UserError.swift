import Foundation

public enum UserError: Error, Equatable, Sendable {
    case network
    case unauthorized
    case validation(message: String)
    case updateFailed
    case storage(message: String)
    case unknown(message: String)
}

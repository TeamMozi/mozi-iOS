import Domain
import Foundation

public protocol OAuthService: Sendable {
    func login() async throws -> String
}

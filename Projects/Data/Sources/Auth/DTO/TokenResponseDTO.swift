import Domain
import Foundation

public struct TokenResponseDTO: Decodable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    public func applying(to session: AuthSession) -> AuthSession {
        AuthSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: session.isNewUser,
            profileCompleted: session.profileCompleted
        )
    }
}

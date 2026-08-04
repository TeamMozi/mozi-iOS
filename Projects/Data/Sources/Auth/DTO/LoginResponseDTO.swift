import Domain
import Foundation

public struct LoginResponseDTO: Decodable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let isNewUser: Bool
    public let profileCompleted: Bool

    public init(
        accessToken: String,
        refreshToken: String,
        isNewUser: Bool,
        profileCompleted: Bool
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isNewUser = isNewUser
        self.profileCompleted = profileCompleted
    }

    public func toDomain() -> AuthSession {
        AuthSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: isNewUser,
            profileCompleted: profileCompleted
        )
    }
}

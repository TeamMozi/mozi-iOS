import Foundation

public struct LoginResponseDTO: Decodable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let userId: Int
    public let isNewUser: Bool
    public let profileCompleted: Bool

    public init(
        accessToken: String,
        refreshToken: String,
        userId: Int,
        isNewUser: Bool,
        profileCompleted: Bool
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
        self.isNewUser = isNewUser
        self.profileCompleted = profileCompleted
    }
}

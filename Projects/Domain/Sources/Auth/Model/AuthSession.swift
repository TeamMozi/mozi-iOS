import Foundation

public struct AuthSession: Equatable, Sendable, Codable {
    public var accessToken: String
    public var refreshToken: String
    public var isNewUser: Bool
    public var profileCompleted: Bool

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
}

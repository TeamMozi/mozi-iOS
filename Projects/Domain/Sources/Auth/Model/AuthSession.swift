import Foundation

public struct AuthSession: Equatable, Sendable {
    public var accessToken: String
    public var refreshToken: String
    public var isNewUser: Bool
    public var profileCompleted: Bool
    public var userID: String

    public init(
        accessToken: String,
        refreshToken: String,
        isNewUser: Bool,
        profileCompleted: Bool,
        userID: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isNewUser = isNewUser
        self.profileCompleted = profileCompleted
        self.userID = userID
    }
}

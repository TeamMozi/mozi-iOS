import Foundation

public struct TokenResponseDTO: Decodable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let userId: Int

    public init(accessToken: String, refreshToken: String, userId: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
    }
}

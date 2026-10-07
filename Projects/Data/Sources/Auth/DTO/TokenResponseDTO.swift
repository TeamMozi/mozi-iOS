import Foundation

struct TokenResponseDTO: Decodable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
}

import Foundation

struct LoginResponseDTO: Decodable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
    let isNewUser: Bool
    let profileCompleted: Bool
}

import Foundation

/// 키체인에 저장되는 형식. 도메인 모델과 따로 둔다.
struct AuthSessionStorageDTO: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let profileCompleted: Bool
    /// 식별자를 저장하기 전에 쓰인 저장분에는 이 이름이 없다. 그래서 선택이다.
    let userID: String?
}

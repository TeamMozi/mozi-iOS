@testable import Data
import Domain
import Foundation
import XCTest

final class LoginResponseDTOMappingTests: XCTestCase {
    func test_LoginResponseDTO가_AuthSession으로_매핑() throws {
        let json = Foundation.Data("""
        {
          "accessToken": "a",
          "refreshToken": "r",
          "isNewUser": true,
          "profileCompleted": false
        }
        """.utf8)
        let dto = try JSONDecoder().decode(LoginResponseDTO.self, from: json)
        XCTAssertEqual(
            dto.toDomain(),
            AuthSession(
                accessToken: "a",
                refreshToken: "r",
                isNewUser: true,
                profileCompleted: false
            )
        )
    }

    func test_TokenResponseDTO가_기존_세션_플래그를_유지한_채_토큰만_교체() {
        let old = AuthSession(
            accessToken: "old-a",
            refreshToken: "old-r",
            isNewUser: true,
            profileCompleted: false
        )
        let dto = TokenResponseDTO(accessToken: "new-a", refreshToken: "new-r")
        XCTAssertEqual(
            dto.applying(to: old),
            AuthSession(
                accessToken: "new-a",
                refreshToken: "new-r",
                isNewUser: true,
                profileCompleted: false
            )
        )
    }
}

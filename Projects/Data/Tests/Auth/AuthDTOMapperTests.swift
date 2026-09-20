@testable import Data
import Domain
import Foundation
import XCTest

final class AuthDTOMapperTests: XCTestCase {
    func test_로그인_응답이_저장_형식으로_바뀌고_식별자가_문자열이_된다() {
        let response = LoginResponseDTO(
            accessToken: "a",
            refreshToken: "r",
            userId: 42,
            isNewUser: true,
            profileCompleted: false
        )

        let stored = AuthDTOMapper.storage(from: response)

        XCTAssertEqual(stored.accessToken, "a")
        XCTAssertEqual(stored.refreshToken, "r")
        XCTAssertEqual(stored.isNewUser, true)
        XCTAssertEqual(stored.profileCompleted, false)
        XCTAssertEqual(stored.userID, "42")
    }

    func test_갱신_응답이_토큰과_식별자만_갈고_상태_둘은_이어_쓴다() {
        let current = AuthSessionStorageDTO(
            accessToken: "old-a",
            refreshToken: "old-r",
            isNewUser: true,
            profileCompleted: true,
            userID: "1"
        )
        let token = TokenResponseDTO(accessToken: "new-a", refreshToken: "new-r", userId: 7)

        let rotated = AuthDTOMapper.storage(from: token, keeping: current)

        XCTAssertEqual(rotated.accessToken, "new-a")
        XCTAssertEqual(rotated.refreshToken, "new-r")
        XCTAssertEqual(rotated.userID, "7")
        XCTAssertEqual(rotated.isNewUser, true)
        XCTAssertEqual(rotated.profileCompleted, true)
    }

    func test_로그인_응답이_도메인_모델로_바로_바뀐다() {
        let response = LoginResponseDTO(
            accessToken: "a",
            refreshToken: "r",
            userId: 42,
            isNewUser: true,
            profileCompleted: false
        )

        XCTAssertEqual(
            AuthDTOMapper.domain(from: response),
            AuthSession(
                accessToken: "a",
                refreshToken: "r",
                isNewUser: true,
                profileCompleted: false,
                userID: "42"
            )
        )
    }

    func test_저장_형식이_도메인_모델로_바뀐다() {
        let stored = AuthSessionStorageDTO(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: false,
            profileCompleted: true,
            userID: "9"
        )

        XCTAssertEqual(
            AuthDTOMapper.domain(from: stored),
            AuthSession(
                accessToken: "a",
                refreshToken: "r",
                isNewUser: false,
                profileCompleted: true,
                userID: "9"
            )
        )
    }

    func test_식별자가_없는_저장분은_도메인_모델이_되지_않는다() {
        let stored = AuthSessionStorageDTO(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: false,
            profileCompleted: true,
            userID: nil
        )

        XCTAssertNil(AuthDTOMapper.domain(from: stored))
    }

    func test_식별자가_없는_옛_저장_JSON_도_디코딩된다() throws {
        let json = """
        {
          "accessToken": "a",
          "refreshToken": "r",
          "isNewUser": false,
          "profileCompleted": true
        }
        """
        let stored = try JSONDecoder().decode(
            AuthSessionStorageDTO.self,
            from: Data(json.utf8)
        )

        XCTAssertNil(stored.userID)
        XCTAssertEqual(stored.accessToken, "a")
    }

    func test_도메인_모델이_저장_형식으로_바뀐다() {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: true,
            profileCompleted: false,
            userID: "3"
        )

        let stored = AuthDTOMapper.storage(from: session)

        XCTAssertEqual(stored.userID, "3")
        XCTAssertEqual(stored.isNewUser, true)
        XCTAssertEqual(stored.profileCompleted, false)
    }
}

import Domain
import XCTest

final class AuthSessionTests: XCTestCase {
    func test_세션_동등성_비교() {
        let a = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: true,
            profileCompleted: false
        )
        let b = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: true,
            profileCompleted: false
        )
        XCTAssertEqual(a, b)
    }

    func test_세션_codable_왕복() throws {
        let original = AuthSession(
            accessToken: "access",
            refreshToken: "refresh",
            isNewUser: false,
            profileCompleted: true
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AuthSession.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_AuthClient_testValue는_빈_클라이언트로_생성() {
        // @DependencyClient 는 testValue = AuthClient() 를 기본 제공한다.
        // 미구현 endpoint 호출 시 issue를 내므로, 생성 가능성만 검증한다.
        _ = AuthClient.testValue
        XCTAssertTrue(true)
    }
}

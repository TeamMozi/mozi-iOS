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

    func test_AuthClient_testValue는_생성_가능() {
        // testValue 는 AuthClient.swift 의 TestDependencyKey 확장이 선언한다.
        // @DependencyClient 는 미구현 클로저를 채운 init 을 제공한다.
        _ = AuthClient.testValue
    }
}

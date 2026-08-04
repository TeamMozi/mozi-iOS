@testable import Data
import Domain
import XCTest

final class AuthLocalDatasourceTests: XCTestCase {
    func test_세션_저장_후_로드() async throws {
        let sut = makeSUT()
        let session = AuthSession(
            accessToken: "access",
            refreshToken: "refresh",
            isNewUser: true,
            profileCompleted: false
        )

        try await sut.save(session)
        let loaded = try await sut.load()

        XCTAssertEqual(loaded, session)
    }

    func test_세션_삭제_후_nil() async throws {
        let sut = makeSUT()
        let session = AuthSession(
            accessToken: "access",
            refreshToken: "refresh",
            isNewUser: false,
            profileCompleted: true
        )
        try await sut.save(session)

        try await sut.clear()
        let loaded = try await sut.load()

        XCTAssertNil(loaded)
    }

    func test_accessToken은_세션_accessToken을_반환() async throws {
        let sut = makeSUT()
        let session = AuthSession(
            accessToken: "access-token-value",
            refreshToken: "refresh",
            isNewUser: false,
            profileCompleted: true
        )
        try await sut.save(session)

        let token = try await sut.accessToken()

        XCTAssertEqual(token, "access-token-value")
    }

    func test_세션_없으면_accessToken_nil() async throws {
        let sut = makeSUT()

        let token = try await sut.accessToken()

        XCTAssertNil(token)
    }

    private func makeSUT() -> AuthLocalDatasource {
        AuthLocalDatasource(keychain: InMemoryKeychainStorage())
    }
}

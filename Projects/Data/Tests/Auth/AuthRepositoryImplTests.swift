import CoreNetwork
@testable import Data
import Domain
import Foundation
import XCTest

final class AuthRepositoryImplTests: XCTestCase {
    func test_카카오_로그인_성공_시_세션_저장() async throws {
        let local = makeLocal()
        let network = FakeNetworkClient(response: .json(loginSuccessJSON))
        let sut = makeSUT(local: local, network: network)

        let session = try await sut.loginWithKakao(accessToken: "kakao-token")

        XCTAssertEqual(session, expectedLoginSession)
        let stored = try await local.load()
        XCTAssertEqual(stored, expectedStoredSession)
        let sent = await network.sentEndpoints
        XCTAssertEqual(sent.map(\.path), ["/api/auth/login/kakao"])
    }

    func test_애플_로그인_성공_시_세션_저장() async throws {
        let local = makeLocal()
        let network = FakeNetworkClient(response: .json(loginSuccessJSON))
        let sut = makeSUT(local: local, network: network)

        let session = try await sut.loginWithApple(identityToken: "apple-token")

        XCTAssertEqual(session, expectedLoginSession)
        let stored = try await local.load()
        XCTAssertEqual(stored, expectedStoredSession)
        let sent = await network.sentEndpoints
        XCTAssertEqual(sent.map(\.path), ["/api/auth/login/apple"])
    }

    func test_dev_로그인_성공_시_세션_저장() async throws {
        let local = makeLocal()
        let network = FakeNetworkClient(response: .json(loginSuccessJSON))
        let sut = makeSUT(local: local, network: network)

        let session = try await sut.loginWithDev()

        XCTAssertEqual(session, expectedLoginSession)
        let stored = try await local.load()
        XCTAssertEqual(stored, expectedStoredSession)
        let sent = await network.sentEndpoints
        XCTAssertEqual(sent.map(\.path), ["/api/auth/login/dev"])
    }

    func test_restoreSession은_로컬만_읽고_네트워크_호출_없음() async throws {
        let local = makeLocal()
        try await local.save(existingStoredSession)
        let network = FakeNetworkClient()
        let sut = makeSUT(local: local, network: network)

        let restored = try await sut.restoreSession()

        XCTAssertEqual(restored, existingSession)
        let sent = await network.sentEndpoints
        XCTAssertTrue(sent.isEmpty)
    }

    func test_logout_원격_실패해도_로컬_세션_삭제() async throws {
        let local = makeLocal()
        try await local.save(existingStoredSession)
        let network = FakeNetworkClient(response: .failure(NetworkError.transport(message: "offline")))
        let sut = makeSUT(local: local, network: network)

        try await sut.logout()

        let stored = try await local.load()
        XCTAssertNil(stored)
        let sent = await network.sentEndpoints
        XCTAssertEqual(sent.map(\.path), ["/api/auth/logout"])
    }

    func test_login_네트워크_실패면_AuthError_network() async throws {
        let local = makeLocal()
        let network = FakeNetworkClient(response: .failure(NetworkError.transport(message: "timed out")))
        let sut = makeSUT(local: local, network: network)

        do {
            _ = try await sut.loginWithKakao(accessToken: "kakao-token")
            XCTFail("expected network")
        } catch let error as AuthError {
            XCTAssertEqual(error, .network)
        } catch {
            XCTFail("unexpected \(error)")
        }

        let stored = try await local.load()
        XCTAssertNil(stored)
    }

    func test_login이_unauthorized면_AuthError_loginFailed() async throws {
        let local = makeLocal()
        let network = FakeNetworkClient(response: .failure(NetworkError.unauthorized))
        let sut = makeSUT(local: local, network: network)

        do {
            _ = try await sut.loginWithApple(identityToken: "apple-token")
            XCTFail("expected loginFailed")
        } catch let error as AuthError {
            XCTAssertEqual(error, .loginFailed)
        } catch {
            XCTFail("unexpected \(error)")
        }

        let stored = try await local.load()
        XCTAssertNil(stored)
    }

    func test_login_키체인_저장_실패면_AuthError_storage() async throws {
        let local = AuthLocalDatasource(
            keychain: FailingKeychainStorage(failingOperations: [.save])
        )
        let sut = makeSUT(local: local, network: FakeNetworkClient(response: .json(loginSuccessJSON)))

        do {
            _ = try await sut.loginWithKakao(accessToken: "kakao-token")
            XCTFail("expected storage")
        } catch let error as AuthError {
            guard case .storage = error else {
                return XCTFail("unexpected \(error)")
            }
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func test_restoreSession_키체인_실패면_AuthError_storage() async throws {
        let local = AuthLocalDatasource(
            keychain: FailingKeychainStorage(failingOperations: [.get])
        )
        let sut = makeSUT(local: local, network: FakeNetworkClient())

        do {
            _ = try await sut.restoreSession()
            XCTFail("expected storage")
        } catch let error as AuthError {
            guard case .storage = error else {
                return XCTFail("unexpected \(error)")
            }
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func test_logout_키체인_삭제_실패면_AuthError_storage() async throws {
        let local = AuthLocalDatasource(
            keychain: FailingKeychainStorage(failingOperations: [.delete])
        )
        let sut = makeSUT(local: local, network: FakeNetworkClient(response: .json(Data())))

        do {
            try await sut.logout()
            XCTFail("expected storage")
        } catch let error as AuthError {
            guard case .storage = error else {
                return XCTFail("unexpected \(error)")
            }
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    // MARK: - Helpers

    private var loginSuccessJSON: Data {
        Data(
            """
            {
              "accessToken":"a1",
              "refreshToken":"r1",
              "userId":1,
              "isNewUser":false,
              "profileCompleted":true
            }
            """.utf8
        )
    }

    private var expectedLoginSession: AuthSession {
        AuthSession(
            accessToken: "a1",
            refreshToken: "r1",
            isNewUser: false,
            profileCompleted: true,
            userID: "1"
        )
    }

    private var expectedStoredSession: AuthSessionStorageDTO {
        AuthSessionStorageDTO(
            accessToken: "a1",
            refreshToken: "r1",
            isNewUser: false,
            profileCompleted: true,
            userID: "1"
        )
    }

    private var existingSession: AuthSession {
        AuthSession(
            accessToken: "old-a",
            refreshToken: "old-r",
            isNewUser: true,
            profileCompleted: false,
            userID: "u1"
        )
    }

    private var existingStoredSession: AuthSessionStorageDTO {
        AuthSessionStorageDTO(
            accessToken: "old-a",
            refreshToken: "old-r",
            isNewUser: true,
            profileCompleted: false,
            userID: "u1"
        )
    }

    private func makeLocal() -> AuthLocalDatasource {
        AuthLocalDatasource(keychain: InMemoryKeychainStorage())
    }

    private func makeSUT(local: AuthLocalDatasource, network: FakeNetworkClient) -> AuthRepositoryImpl {
        // logout 실패/성공 검증에는 authed 조립 순환이 필요 없으므로 같은 가짜를 두 자리에 넣는다.
        let remote = AuthRemoteDatasource(
            plainClient: network,
            authedClient: network
        )
        return AuthRepositoryImpl(remote: remote, local: local)
    }
}

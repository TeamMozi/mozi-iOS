@testable import Data
import CoreNetwork
import Domain
import Foundation
import XCTest

final class AuthRepositoryImplTests: XCTestCase {
    override func setUp() async throws {
        AuthURLProtocolStub.reset()
    }

    override func tearDown() async throws {
        AuthURLProtocolStub.reset()
    }

    func test_카카오_로그인_성공_시_세션_저장() async throws {
        let local = makeLocal()
        stubLoginSuccess()
        let sut = try makeSUT(local: local)

        let session = try await sut.loginWithKakao(accessToken: "kakao-token")

        XCTAssertEqual(session, expectedLoginSession)
        let stored = try await local.load()
        XCTAssertEqual(stored, expectedLoginSession)
        XCTAssertEqual(AuthURLProtocolStub.requests.count, 1)
        XCTAssertEqual(AuthURLProtocolStub.requests.first?.url?.path, "/api/auth/login/kakao")
    }

    func test_애플_로그인_성공_시_세션_저장() async throws {
        let local = makeLocal()
        stubLoginSuccess()
        let sut = try makeSUT(local: local)

        let session = try await sut.loginWithApple(identityToken: "apple-token")

        XCTAssertEqual(session, expectedLoginSession)
        let stored = try await local.load()
        XCTAssertEqual(stored, expectedLoginSession)
        XCTAssertEqual(AuthURLProtocolStub.requests.count, 1)
        XCTAssertEqual(AuthURLProtocolStub.requests.first?.url?.path, "/api/auth/login/apple")
    }

    func test_dev_로그인_성공_시_세션_저장() async throws {
        let local = makeLocal()
        stubLoginSuccess()
        let sut = try makeSUT(local: local)

        let session = try await sut.loginWithDev()

        XCTAssertEqual(session, expectedLoginSession)
        let stored = try await local.load()
        XCTAssertEqual(stored, expectedLoginSession)
        XCTAssertEqual(AuthURLProtocolStub.requests.count, 1)
        XCTAssertEqual(AuthURLProtocolStub.requests.first?.url?.path, "/api/auth/login/dev")
    }

    func test_restoreSession은_로컬만_읽고_네트워크_호출_없음() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        AuthURLProtocolStub.requestHandler = { _ in
            XCTFail("restoreSession must not call network")
            return .init(statusCode: 500, headers: [:], data: Data())
        }
        let sut = try makeSUT(local: local)

        let restored = try await sut.restoreSession()

        XCTAssertEqual(restored, existingSession)
        XCTAssertTrue(AuthURLProtocolStub.requests.isEmpty)
    }

    func test_logout_원격_실패해도_로컬_세션_삭제() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        AuthURLProtocolStub.requestHandler = { _ in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        }
        let sut = try makeSUT(local: local)

        try await sut.logout()

        let stored = try await local.load()
        XCTAssertNil(stored)
    }

    func test_login_네트워크_실패면_AuthError_network() async throws {
        let local = makeLocal()
        AuthURLProtocolStub.requestHandler = { _ in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        }
        let sut = try makeSUT(local: local)

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

    func test_login_401이면_AuthError_loginFailed() async throws {
        let local = makeLocal()
        AuthURLProtocolStub.requestHandler = { _ in
            .init(
                statusCode: 401,
                headers: [:],
                data: Data(#"{"message":"invalid token"}"#.utf8)
            )
        }
        let sut = try makeSUT(local: local)

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

    func test_restoreSession_키체인_실패면_AuthError_storage() async throws {
        let local = AuthLocalDatasource(
            keychain: FailingKeychainStorage(failingOperations: [.get])
        )
        let sut = try makeSUT(local: local)

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
        AuthURLProtocolStub.requestHandler = { _ in
            .init(statusCode: 200, headers: [:], data: Data())
        }
        let sut = try makeSUT(local: local)

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

    private var expectedLoginSession: AuthSession {
        AuthSession(
            accessToken: "a1",
            refreshToken: "r1",
            isNewUser: false,
            profileCompleted: true
        )
    }

    private var existingSession: AuthSession {
        AuthSession(
            accessToken: "old-a",
            refreshToken: "old-r",
            isNewUser: true,
            profileCompleted: false
        )
    }

    private func stubLoginSuccess() {
        AuthURLProtocolStub.requestHandler = { _ in
            .init(
                statusCode: 200,
                headers: [:],
                data: Data(
                    """
                    {
                      "accessToken":"a1",
                      "refreshToken":"r1",
                      "isNewUser":false,
                      "profileCompleted":true
                    }
                    """.utf8
                )
            )
        }
    }

    private func makeLocal() -> AuthLocalDatasource {
        AuthLocalDatasource(keychain: InMemoryKeychainStorage())
    }

    private func makeSUT(local: AuthLocalDatasource) throws -> AuthRepositoryImpl {
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let configuration = NetworkConfiguration(baseURL: baseURL)
        let plainClient = DefaultNetworkClient.plain(
            configuration: configuration,
            session: AuthTestSessionFactory.make()
        )
        // logout 실패/성공 검증에는 authed 조립 순환이 필요 없으므로 plain을 재사용한다.
        let remote = AuthRemoteDatasource(
            plainClient: plainClient,
            authedClient: plainClient
        )
        return AuthRepositoryImpl(remote: remote, local: local)
    }
}

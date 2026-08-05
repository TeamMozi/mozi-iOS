@testable import Data
import CoreNetwork
import Domain
import Foundation
import XCTest

final class AuthClientFactoryTests: XCTestCase {
    override func setUp() async throws {
        AuthURLProtocolStub.reset()
    }

    override func tearDown() async throws {
        AuthURLProtocolStub.reset()
    }

    func test_factory가_restore_logout_currentSession을_repository에_연결() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        AuthURLProtocolStub.requestHandler = { request in
            if request.url?.path == "/api/auth/logout" {
                return .init(statusCode: 200, headers: [:], data: Data())
            }
            XCTFail("unexpected network call: \(request.url?.absoluteString ?? "nil")")
            return .init(statusCode: 500, headers: [:], data: Data())
        }

        let sut = AuthClientFactory.make(
            repository: try makeRepository(local: local),
            credentialProvider: { _ in
                XCTFail("credentialProvider must not be called")
                return "unused"
            }
        )

        let restored = try await sut.restoreSession()
        let current = await sut.currentSession()
        try await sut.logout()
        let afterLogout = await sut.currentSession()

        XCTAssertEqual(restored, existingSession)
        XCTAssertEqual(current, existingSession)
        XCTAssertNil(afterLogout)
        XCTAssertEqual(AuthURLProtocolStub.requests.count, 1)
        XCTAssertEqual(AuthURLProtocolStub.requests.first?.url?.path, "/api/auth/logout")
    }

    func test_factory_login_kakao가_자격증명_클로저_후_repository_login을_호출() async throws {
        let local = makeLocal()
        let probe = CredentialProbe()
        stubLoginSuccess()

        let sut = AuthClientFactory.make(
            repository: try makeRepository(local: local),
            credentialProvider: { provider in
                await probe.record(provider)
                XCTAssertEqual(provider, .kakao)
                return "kakao-token"
            }
        )

        let session = try await sut.login(.kakao)
        let providers = await probe.providers
        let stored = try await local.load()

        XCTAssertEqual(session, expectedLoginSession)
        XCTAssertEqual(stored, expectedLoginSession)
        XCTAssertEqual(providers, [.kakao])
        XCTAssertEqual(AuthURLProtocolStub.requests.count, 1)
        XCTAssertEqual(AuthURLProtocolStub.requests.first?.url?.path, "/api/auth/login/kakao")
        let body = try XCTUnwrap(AuthURLProtocolStub.requests.first?.httpBody)
        let bodyString = try XCTUnwrap(String(bytes: body, encoding: .utf8))
        XCTAssertTrue(bodyString.contains("kakao-token"))
    }

    func test_factory_login_apple이_자격증명_클로저_후_repository_login을_호출() async throws {
        let local = makeLocal()
        let probe = CredentialProbe()
        stubLoginSuccess()

        let sut = AuthClientFactory.make(
            repository: try makeRepository(local: local),
            credentialProvider: { provider in
                await probe.record(provider)
                XCTAssertEqual(provider, .apple)
                return "apple-token"
            }
        )

        let session = try await sut.login(.apple)
        let providers = await probe.providers
        let stored = try await local.load()

        XCTAssertEqual(session, expectedLoginSession)
        XCTAssertEqual(stored, expectedLoginSession)
        XCTAssertEqual(providers, [.apple])
        XCTAssertEqual(AuthURLProtocolStub.requests.count, 1)
        XCTAssertEqual(AuthURLProtocolStub.requests.first?.url?.path, "/api/auth/login/apple")
        let body = try XCTUnwrap(AuthURLProtocolStub.requests.first?.httpBody)
        let bodyString = try XCTUnwrap(String(bytes: body, encoding: .utf8))
        XCTAssertTrue(bodyString.contains("apple-token"))
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

    private func makeRepository(local: AuthLocalDatasource) throws -> AuthRepositoryImpl {
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let configuration = NetworkConfiguration(baseURL: baseURL)
        let plainClient = DefaultNetworkClient.plain(
            configuration: configuration,
            session: AuthTestSessionFactory.make()
        )
        let remote = AuthRemoteDatasource(
            plainClient: plainClient,
            authedClient: plainClient
        )
        return AuthRepositoryImpl(remote: remote, local: local)
    }
}

private actor CredentialProbe {
    private(set) var providers: [AuthProvider] = []

    func record(_ provider: AuthProvider) {
        providers.append(provider)
    }
}

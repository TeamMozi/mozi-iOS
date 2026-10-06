import CoreNetwork
import CoreSocialAuth
@testable import Data
import Domain
import Foundation
import XCTest

final class AuthClientFactoryTests: XCTestCase {
    func test_factory가_restore_logout_currentSession을_repository에_연결() async throws {
        let local = makeLocal()
        try await local.save(existingStoredSession)
        let network = FakeNetworkClient(response: .json(Data()))
        let sut = AuthClientFactory.make(
            session: makeAssembly(local: local, network: network, probe: CredentialProbe())
        )

        let restored = try await sut.restoreSession()
        let current = await sut.currentSession()
        try await sut.logout()
        let afterLogout = await sut.currentSession()

        XCTAssertEqual(restored, existingSession)
        XCTAssertEqual(current, existingSession)
        XCTAssertNil(afterLogout)
        let sent = await network.sentEndpoints
        XCTAssertEqual(sent.map(\.path), ["/api/auth/logout"])
        XCTAssertEqual(sent.first?.method, .post)
    }

    func test_factory_login_kakao가_자격증명_클로저_후_repository_login을_호출() async throws {
        let local = makeLocal()
        let probe = CredentialProbe()
        let network = FakeNetworkClient(response: .json(loginSuccessJSON))
        let sut = AuthClientFactory.make(session: makeAssembly(local: local, network: network, probe: probe))

        let session = try await sut.login(.kakao)
        let providers = await probe.providers
        let stored = try await local.load()
        let sent = await network.sentEndpoints

        XCTAssertEqual(session, expectedLoginSession)
        XCTAssertEqual(stored, expectedStoredSession)
        XCTAssertEqual(providers, [.kakao])
        XCTAssertEqual(sent.map(\.path), ["/api/auth/login/kakao"])
        let body = try XCTUnwrap(sent.first?.body)
        let bodyString = try XCTUnwrap(String(bytes: body, encoding: .utf8))
        XCTAssertTrue(bodyString.contains("credential"))
    }

    func test_factory_login_apple이_자격증명_클로저_후_repository_login을_호출() async throws {
        let local = makeLocal()
        let probe = CredentialProbe()
        let network = FakeNetworkClient(response: .json(loginSuccessJSON))
        let sut = AuthClientFactory.make(session: makeAssembly(local: local, network: network, probe: probe))

        let session = try await sut.login(.apple)
        let providers = await probe.providers
        let stored = try await local.load()
        let sent = await network.sentEndpoints

        XCTAssertEqual(session, expectedLoginSession)
        XCTAssertEqual(stored, expectedStoredSession)
        XCTAssertEqual(providers, [.apple])
        XCTAssertEqual(sent.map(\.path), ["/api/auth/login/apple"])
        let body = try XCTUnwrap(sent.first?.body)
        let bodyString = try XCTUnwrap(String(bytes: body, encoding: .utf8))
        XCTAssertTrue(bodyString.contains("credential"))
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

    private func makeAssembly(
        local: AuthLocalDatasource,
        network: FakeNetworkClient,
        probe: CredentialProbe
    ) -> AuthSessionAssembly {
        AuthSessionAssembly(
            plainClient: network,
            authedClient: network,
            uploader: FakeUploader(),
            local: local,
            socialAuthServices: SocialAuthServices(
                kakao: ProbingSocialAuthService(provider: .kakao, probe: probe),
                apple: ProbingSocialAuthService(provider: .apple, probe: probe)
            )
        )
    }
}

private actor CredentialProbe {
    private(set) var providers: [AuthProvider] = []

    func record(_ provider: AuthProvider) {
        providers.append(provider)
    }
}

private struct ProbingSocialAuthService: SocialAuthService {
    let provider: AuthProvider
    let probe: CredentialProbe

    func login() async throws -> String {
        await probe.record(provider)
        return "credential"
    }
}

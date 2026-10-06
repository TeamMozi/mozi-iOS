import CoreNetwork
@testable import Data
import Domain
import Foundation
import XCTest

final class AuthTokenRefresherTests: XCTestCase {
    func test_refresh_성공_시_새_refreshToken으로_교체_저장() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        let network = FakeNetworkClient(
            response: .json(Data(#"{"accessToken":"a2","refreshToken":"r2","userId":1}"#.utf8))
        )
        let sut = makeSUT(local: local, network: network)

        try await sut.refresh()

        let stored = try await local.load()
        XCTAssertEqual(
            stored,
            AuthSessionStorageDTO(
                accessToken: "a2",
                refreshToken: "r2",
                isNewUser: true,
                profileCompleted: false,
                userID: "1"
            )
        )
        let sent = await network.sentEndpoints
        XCTAssertEqual(sent.map(\.path), ["/api/auth/refresh"])
    }

    func test_refresh가_unauthorized면_세션_삭제_후_unauthorized() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        let network = FakeNetworkClient(response: .failure(NetworkError.unauthorized))
        let sut = makeSUT(local: local, network: network)

        do {
            try await sut.refresh()
            XCTFail("expected unauthorized")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("unexpected \(error)")
        }

        let stored = try await local.load()
        XCTAssertNil(stored)
    }

    func test_refresh_네트워크_실패면_세션_유지_후_network() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        let network = FakeNetworkClient(response: .failure(NetworkError.transport(message: "timed out")))
        let sut = makeSUT(local: local, network: network)

        do {
            try await sut.refresh()
            XCTFail("expected network")
        } catch let error as AuthError {
            XCTAssertEqual(error, .network)
        } catch {
            XCTFail("unexpected \(error)")
        }

        let stored = try await local.load()
        XCTAssertEqual(stored, existingSession)
    }

    func test_세션_없으면_unauthorized_이고_네트워크_호출_없음() async throws {
        let network = FakeNetworkClient()
        let sut = makeSUT(local: makeLocal(), network: network)

        do {
            try await sut.refresh()
            XCTFail("expected unauthorized")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("unexpected \(error)")
        }

        let sent = await network.sentEndpoints
        XCTAssertTrue(sent.isEmpty)
    }

    func test_refresh가_badRequest면_세션_유지_후_unknown() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        let network = FakeNetworkClient(response: .failure(NetworkError.badRequest(message: "bad request")))
        let sut = makeSUT(local: local, network: network)

        do {
            try await sut.refresh()
            XCTFail("expected unknown")
        } catch let error as AuthError {
            guard case .unknown = error else {
                return XCTFail("unexpected \(error)")
            }
        } catch {
            XCTFail("unexpected \(error)")
        }

        let stored = try await local.load()
        XCTAssertEqual(stored, existingSession)
    }

    func test_refresh_키체인_로드_실패면_AuthError_storage() async throws {
        let local = AuthLocalDatasource(
            keychain: FailingKeychainStorage(failingOperations: [.get])
        )
        let network = FakeNetworkClient()
        let sut = makeSUT(local: local, network: network)

        do {
            try await sut.refresh()
            XCTFail("expected storage")
        } catch let error as AuthError {
            guard case .storage = error else {
                return XCTFail("unexpected \(error)")
            }
        } catch {
            XCTFail("unexpected \(error)")
        }

        let sent = await network.sentEndpoints
        XCTAssertTrue(sent.isEmpty)
    }

    private var existingSession: AuthSessionStorageDTO {
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

    private func makeSUT(local: AuthLocalDatasource, network: FakeNetworkClient) -> AuthTokenRefresher {
        // refresh는 plain only. authed 순환을 피하기 위해 plain을 재사용한다.
        let remote = AuthRemoteDatasource(
            plainClient: network,
            authedClient: network
        )
        return AuthTokenRefresher(remote: remote, local: local)
    }
}

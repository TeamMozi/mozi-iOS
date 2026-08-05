@testable import Data
import CoreNetwork
import Domain
import Foundation
import XCTest

final class AuthTokenRefresherTests: XCTestCase {
    override func setUp() async throws {
        AuthURLProtocolStub.reset()
    }

    override func tearDown() async throws {
        AuthURLProtocolStub.reset()
    }

    func test_refresh_성공_시_새_refreshToken으로_교체_저장() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        AuthURLProtocolStub.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/api/auth/refresh")
            return .init(
                statusCode: 200,
                headers: [:],
                data: Data(#"{"accessToken":"a2","refreshToken":"r2"}"#.utf8)
            )
        }
        let sut = try makeSUT(local: local)

        try await sut.refresh()

        let stored = try await local.load()
        XCTAssertEqual(
            stored,
            AuthSession(
                accessToken: "a2",
                refreshToken: "r2",
                isNewUser: true,
                profileCompleted: false
            )
        )
        XCTAssertEqual(AuthURLProtocolStub.requests.count, 1)
    }

    func test_refresh_401이면_세션_삭제_후_unauthorized() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        AuthURLProtocolStub.requestHandler = { _ in
            .init(
                statusCode: 401,
                headers: [:],
                data: Data(#"{"message":"expired"}"#.utf8)
            )
        }
        let sut = try makeSUT(local: local)

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
        AuthURLProtocolStub.requestHandler = { _ in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        }
        let sut = try makeSUT(local: local)

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
        AuthURLProtocolStub.requestHandler = { _ in
            XCTFail("refresh without session must not call network")
            return .init(statusCode: 500, headers: [:], data: Data())
        }
        let sut = try makeSUT(local: makeLocal())

        do {
            try await sut.refresh()
            XCTFail("expected unauthorized")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("unexpected \(error)")
        }

        XCTAssertTrue(AuthURLProtocolStub.requests.isEmpty)
    }

    func test_refresh_400이면_세션_유지_후_unknown() async throws {
        let local = makeLocal()
        try await local.save(existingSession)
        AuthURLProtocolStub.requestHandler = { _ in
            .init(
                statusCode: 400,
                headers: [:],
                data: Data(#"{"message":"bad request"}"#.utf8)
            )
        }
        let sut = try makeSUT(local: local)

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
        let sut = try makeSUT(local: local)

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
    }

    private var existingSession: AuthSession {
        AuthSession(
            accessToken: "old-a",
            refreshToken: "old-r",
            isNewUser: true,
            profileCompleted: false
        )
    }

    private func makeLocal() -> AuthLocalDatasource {
        AuthLocalDatasource(keychain: InMemoryKeychainStorage())
    }

    private func makeSUT(local: AuthLocalDatasource) throws -> AuthTokenRefresher {
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let configuration = NetworkConfiguration(baseURL: baseURL)
        let plainClient = DefaultNetworkClient.plain(
            configuration: configuration,
            session: AuthTestSessionFactory.make()
        )
        // refresh는 plain only. authed 순환을 피하기 위해 plain을 재사용한다.
        let remote = AuthRemoteDatasource(
            plainClient: plainClient,
            authedClient: plainClient
        )
        return AuthTokenRefresher(remote: remote, local: local)
    }
}

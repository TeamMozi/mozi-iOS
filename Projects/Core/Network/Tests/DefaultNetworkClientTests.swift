import CoreNetwork
import XCTest

final class DefaultNetworkClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.reset()
        super.tearDown()
    }

    func test_request_buildsMethodPathQueryHeadersAndBody() async throws {
        URLProtocolStub.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/api/auth/login/kakao")
            XCTAssertEqual(request.url?.query, "debug=1")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "1")
            XCTAssertEqual(request.httpBody, Data(#"{"accessToken":"k"}"#.utf8))
            return .init(statusCode: 200, headers: [:], data: Data(#"{"ok":true}"#.utf8))
        }

        struct OK: Decodable, Equatable { let ok: Bool }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let client = DefaultNetworkClient.plain(
            configuration: NetworkConfiguration(baseURL: baseURL),
            session: TestSessionFactory.make()
        )

        let endpoint = TestEndpoint(
            path: "/api/auth/login/kakao",
            method: .post,
            headers: ["X-Test": "1", "Content-Type": "application/json"],
            queryItems: [.init(name: "debug", value: "1")],
            body: Data(#"{"accessToken":"k"}"#.utf8)
        )

        let response: OK = try await client.request(endpoint)
        XCTAssertEqual(response, OK(ok: true))
    }

    func test_voidRequest_succeedsOn2xxAndIgnoresBody() async throws {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 204, headers: [:], data: Data(#"{"ignored":true}"#.utf8))
        }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let client = DefaultNetworkClient.plain(
            configuration: NetworkConfiguration(baseURL: baseURL),
            session: TestSessionFactory.make()
        )
        try await client.request(TestEndpoint(path: "/api/auth/logout", method: .post))
    }

    func test_requestDecodable_emptyBody_throwsDecodingFailed() async {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 204, headers: [:], data: Data())
        }
        struct Dummy: Decodable { let value: Int }
        guard let baseURL = URL(string: "https://api.example.invalid") else {
            XCTFail("invalid base URL")
            return
        }
        let client = DefaultNetworkClient.plain(
            configuration: NetworkConfiguration(baseURL: baseURL),
            session: TestSessionFactory.make()
        )
        do {
            let _: Dummy = try await client.request(TestEndpoint())
            XCTFail("expected decodingFailed")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func test_authedRequest_attachesBearerToken() async throws {
        URLProtocolStub.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer access-token")
            return .init(statusCode: 200, headers: [:], data: Data(#"{"ok":true}"#.utf8))
        }

        struct OK: Decodable { let ok: Bool }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let provider = StubTokenProvider(token: "access-token")
        let refresher = StubTokenRefresher()
        let client = DefaultNetworkClient.authed(
            configuration: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: provider,
            tokenRefresher: refresher,
            session: TestSessionFactory.make()
        )

        let _: OK = try await client.request(TestEndpoint())
    }

    func test_authed401_refreshesOnceAndRetries() async throws {
        final class CodeQueue: @unchecked Sendable {
            private let lock = NSLock()
            private var codes = [401, 200]

            func next() -> Int {
                lock.lock()
                defer { lock.unlock() }
                return codes.removeFirst()
            }
        }

        let queue = CodeQueue()
        URLProtocolStub.requestHandler = { _ in
            let code = queue.next()
            if code == 200 {
                return .init(statusCode: 200, headers: [:], data: Data(#"{"ok":true}"#.utf8))
            }
            return .init(statusCode: 401, headers: [:], data: Data(#"{"message":"expired"}"#.utf8))
        }

        struct OK: Decodable, Equatable { let ok: Bool }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let provider = StubTokenProvider(token: "access-token")
        let refresher = StubTokenRefresher()
        let client = DefaultNetworkClient.authed(
            configuration: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: provider,
            tokenRefresher: refresher,
            session: TestSessionFactory.make()
        )

        let value: OK = try await client.request(TestEndpoint())
        XCTAssertEqual(value.ok, true)
        let refreshCount = await refresher.refreshCount
        XCTAssertEqual(refreshCount, 1)
        XCTAssertEqual(URLProtocolStub.requests.count, 2)
    }

    func test_concurrent401_singleFlightRefresh() async throws {
        final class RequestCounter: @unchecked Sendable {
            private let lock = NSLock()
            private var requestIndex = 0

            func next() -> Int {
                lock.lock()
                defer { lock.unlock() }
                requestIndex += 1
                return requestIndex
            }
        }

        let counter = RequestCounter()
        URLProtocolStub.requestHandler = { _ in
            let requestIndex = counter.next()
            // first 3 are original 401s, next 3 are retries 200
            if requestIndex <= 3 {
                return .init(statusCode: 401, headers: [:], data: Data(#"{"message":"expired"}"#.utf8))
            }
            return .init(statusCode: 200, headers: [:], data: Data(#"{"ok":true}"#.utf8))
        }

        struct OK: Decodable { let ok: Bool }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let provider = StubTokenProvider(token: "access-token")
        let refresher = StubTokenRefresher()
        let client = DefaultNetworkClient.authed(
            configuration: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: provider,
            tokenRefresher: refresher,
            session: TestSessionFactory.make()
        )

        async let a: OK = client.request(TestEndpoint(path: "/a"))
        async let b: OK = client.request(TestEndpoint(path: "/b"))
        async let c: OK = client.request(TestEndpoint(path: "/c"))
        _ = try await (a, b, c)

        let refreshCount = await refresher.refreshCount
        XCTAssertEqual(refreshCount, 1)
        XCTAssertEqual(URLProtocolStub.requests.count, 6)
    }

    func test_refreshFailure_mapsToUnauthorized() async {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 401, headers: [:], data: Data(#"{"message":"expired"}"#.utf8))
        }

        guard let baseURL = URL(string: "https://api.example.invalid") else {
            XCTFail("invalid base URL")
            return
        }
        let provider = StubTokenProvider(token: "access-token")
        let refresher = StubTokenRefresher()
        await refresher.setError(NetworkError.serverError(statusCode: 500, message: "refresh failed"))
        let client = DefaultNetworkClient.authed(
            configuration: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: provider,
            tokenRefresher: refresher,
            session: TestSessionFactory.make()
        )

        do {
            let _: Dummy = try await client.request(TestEndpoint())
            XCTFail("expected unauthorized")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func test_retryStill401_mapsToUnauthorized() async {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 401, headers: [:], data: Data(#"{"message":"expired"}"#.utf8))
        }

        guard let baseURL = URL(string: "https://api.example.invalid") else {
            XCTFail("invalid base URL")
            return
        }
        let client = DefaultNetworkClient.authed(
            configuration: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: StubTokenProvider(token: "access-token"),
            tokenRefresher: StubTokenRefresher(),
            session: TestSessionFactory.make()
        )

        do {
            let _: Dummy = try await client.request(TestEndpoint())
            XCTFail("expected unauthorized")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    private struct Dummy: Decodable { let value: Int }
}

import CoreNetwork
import XCTest

final class DefaultNetworkClientReviewFixTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.reset()
        super.tearDown()
    }

    func test_인증_HTTP_URL이면_authorization_거부() async {
        URLProtocolStub.requestHandler = { _ in
            XCTFail("request should not be sent")
            return .init(statusCode: 200, headers: [:], data: Data())
        }

        guard let baseURL = URL(string: "http://api.example.invalid") else {
            XCTFail("invalid base URL")
            return
        }
        let provider = StubTokenProvider(token: "access-token")
        let refresher = StubTokenRefresher(provider: provider)
        let client = DefaultNetworkClient.authed(
            configuration: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: provider,
            tokenRefresher: refresher,
            session: TestSessionFactory.make()
        )

        do {
            let _: Dummy = try await client.request(TestEndpoint())
            XCTFail("expected invalidURL")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func test_refresh_이후_늦은_401은_재refresh하지_않음() async throws {
        final class RequestCounter: @unchecked Sendable {
            private let lock = NSLock()
            private var count = 0

            func next() -> Int {
                lock.lock()
                defer { lock.unlock() }
                count += 1
                return count
            }
        }

        let counter = RequestCounter()
        URLProtocolStub.requestHandler = { _ in
            let index = counter.next()
            if index == 1 {
                return .init(
                    statusCode: 401,
                    headers: [:],
                    data: Data(#"{"message":"expired"}"#.utf8)
                )
            }
            if index == 2 {
                // 이전 토큰 generation 으로 시작한 요청의 늦은 401
                Thread.sleep(forTimeInterval: 0.25)
                return .init(
                    statusCode: 401,
                    headers: [:],
                    data: Data(#"{"message":"expired"}"#.utf8)
                )
            }
            return .init(statusCode: 200, headers: [:], data: Data(#"{"ok":true}"#.utf8))
        }

        struct OkPayload: Decodable { let ok: Bool }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let provider = StubTokenProvider(token: "access-token")
        let refresher = StubTokenRefresher(provider: provider, nextToken: "access-token-2")
        await refresher.setDelayNanoseconds(50_000_000)
        let client = DefaultNetworkClient.authed(
            configuration: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: provider,
            tokenRefresher: refresher,
            session: TestSessionFactory.make()
        )

        async let first: OkPayload = client.request(TestEndpoint(path: "/first"))
        try await Task.sleep(nanoseconds: 20_000_000)
        async let second: OkPayload = client.request(TestEndpoint(path: "/second"))
        _ = try await (first, second)

        let refreshCount = await refresher.refreshCount
        XCTAssertEqual(refreshCount, 1)
    }

    private struct Dummy: Decodable { let value: Int }
}

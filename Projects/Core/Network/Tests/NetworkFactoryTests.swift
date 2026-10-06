import CoreNetwork
import XCTest

final class NetworkFactoryTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.reset()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        URLProtocolStub.reset()
        super.tearDown()
    }

    func test_makePlain은_설정의_주소로_보내고_Authorization을_붙이지_않는다() async throws {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 200, headers: [:], data: Data(#"{"ok":true}"#.utf8))
        }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let client = NetworkFactory.makePlain(config: NetworkConfiguration(baseURL: baseURL))

        let response: OkPayload = try await client.request(TestEndpoint(path: "/api/ping"))

        XCTAssertEqual(response, OkPayload(ok: true))
        let request = try XCTUnwrap(URLProtocolStub.requests.first)
        XCTAssertEqual(request.url?.host, "api.example.invalid")
        XCTAssertEqual(request.url?.path, "/api/ping")
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    func test_makeAuthed는_토큰을_Authorization에_붙인다() async throws {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 200, headers: [:], data: Data(#"{"ok":true}"#.utf8))
        }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let client = NetworkFactory.makeAuthed(
            config: NetworkConfiguration(baseURL: baseURL),
            tokenProvider: StubTokenProvider(token: "access-token"),
            tokenRefresher: StubTokenRefresher()
        )

        let _: OkPayload = try await client.request(TestEndpoint(path: "/api/users/me"))

        let request = try XCTUnwrap(URLProtocolStub.requests.first)
        XCTAssertEqual(request.url?.path, "/api/users/me")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer access-token")
    }

    func test_makeUploader는_받은_주소로_PUT을_보낸다() async throws {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 200, headers: [:], data: Data())
        }
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/upload?token=signed"))
        let uploader = NetworkFactory.makeUploader()

        try await uploader.upload(Data([0x01]), to: url, contentType: "image/png", onProgress: { _ in })

        let request = try XCTUnwrap(URLProtocolStub.requests.first)
        XCTAssertEqual(request.httpMethod, "PUT")
        XCTAssertEqual(request.url, url)
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    private struct OkPayload: Decodable, Equatable, Sendable { let ok: Bool }
}

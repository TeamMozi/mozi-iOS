import CoreNetwork
import XCTest

final class URLRequestBuildingTests: XCTestCase {
    func test_엔드포인트_기본값이_비어_있음() {
        struct MinimalEndpoint: APIEndpoint {
            let path = "/ping"
            let method = HTTPMethod.get
        }

        let endpoint = MinimalEndpoint()
        XCTAssertEqual(endpoint.headers, [:])
        XCTAssertEqual(endpoint.queryItems, [])
        XCTAssertNil(endpoint.body)
    }

    func test_네트워크_설정_기본값이_기대값() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.com"))
        let configuration = NetworkConfiguration(baseURL: baseURL)
        XCTAssertEqual(configuration.baseURL, baseURL)
        XCTAssertEqual(configuration.timeout, 30)
        _ = configuration.jsonDecoder
        _ = configuration.jsonEncoder
    }

    func test_토큰_스텁이_accessToken과_refresh를_제공() async throws {
        let provider = StubTokenProvider()
        let refresher = StubTokenRefresher()
        let token = try await provider.accessToken()
        XCTAssertEqual(token, "access-token")
        try await refresher.refresh()
        let count = await refresher.refreshCount
        XCTAssertEqual(count, 1)
    }
}

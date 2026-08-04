import CoreNetwork
import XCTest

final class URLRequestBuildingTests: XCTestCase {
    func test_endpointDefaults_areEmpty() {
        struct MinimalEndpoint: APIEndpoint {
            let path = "/ping"
            let method = HTTPMethod.get
        }

        let endpoint = MinimalEndpoint()
        XCTAssertEqual(endpoint.headers, [:])
        XCTAssertEqual(endpoint.queryItems, [])
        XCTAssertNil(endpoint.body)
    }

    func test_networkConfiguration_defaults() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.com"))
        let configuration = NetworkConfiguration(baseURL: baseURL)
        XCTAssertEqual(configuration.baseURL, baseURL)
        XCTAssertEqual(configuration.timeout, 30)
        _ = configuration.jsonDecoder
        _ = configuration.jsonEncoder
    }

    func test_tokenStubs_compile() async throws {
        let provider = StubTokenProvider()
        let refresher = StubTokenRefresher()
        let token = try await provider.accessToken()
        XCTAssertEqual(token, "access-token")
        try await refresher.refresh()
        let count = await refresher.refreshCount
        XCTAssertEqual(count, 1)
    }
}

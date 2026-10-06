import CoreNetwork
@testable import Data
import Domain
import Foundation
import XCTest

final class PageRequestQueryTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AuthURLProtocolStub.reset()
    }

    override func tearDown() {
        AuthURLProtocolStub.reset()
        super.tearDown()
    }

    func test_첫_쪽_요청은_page_0_size_20_쿼리가_된다() {
        XCTAssertEqual(
            PageRequest.first.queryItems,
            [URLQueryItem(name: "page", value: "0"), URLQueryItem(name: "size", value: "20")]
        )
    }

    func test_쪽_쿼리는_펼친_꼴로_요청_주소에_붙는다() async throws {
        AuthURLProtocolStub.requestHandler = { _ in
            .init(
                statusCode: 200,
                headers: [:],
                data: Data(#"{"content":[],"number":2,"size":20,"last":true}"#.utf8)
            )
        }
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))
        let client = DefaultNetworkClient.plain(
            configuration: NetworkConfiguration(baseURL: baseURL),
            session: AuthTestSessionFactory.make()
        )

        let _: PageResponseDTO<TestItemDTO> = try await client.request(
            PageTestEndpoint(queryItems: PageRequest(page: 2, size: 20).queryItems)
        )

        XCTAssertEqual(AuthURLProtocolStub.requests.first?.url?.query, "page=2&size=20")
    }
}

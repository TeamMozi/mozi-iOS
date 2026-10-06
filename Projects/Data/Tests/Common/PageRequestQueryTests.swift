@testable import Data
import Domain
import Foundation
import XCTest

final class PageRequestQueryTests: XCTestCase {
    func test_첫_페이지_요청은_page_0_size_20_쿼리가_된다() {
        XCTAssertEqual(
            PageRequest.first.queryItems,
            [URLQueryItem(name: "page", value: "0"), URLQueryItem(name: "size", value: "20")]
        )
    }

    func test_페이지_쿼리는_펼친_꼴로_보내는_endpoint에_실린다() async throws {
        let network = FakeNetworkClient(
            response: .json(Data(#"{"content":[],"number":2,"size":20,"last":true}"#.utf8))
        )

        let _: PageResponseDTO<TestItemDTO> = try await network.request(
            PageTestEndpoint(queryItems: PageRequest(page: 2, size: 20).queryItems)
        )

        let sent = await network.sentEndpoints
        XCTAssertEqual(
            sent.first?.queryItems,
            [URLQueryItem(name: "page", value: "2"), URLQueryItem(name: "size", value: "20")]
        )
    }
}

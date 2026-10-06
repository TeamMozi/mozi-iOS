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
}

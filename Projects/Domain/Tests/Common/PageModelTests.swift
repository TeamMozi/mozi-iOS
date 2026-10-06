import Domain
import XCTest

final class PageModelTests: XCTestCase {
    func test_첫_쪽_요청은_0쪽_20개() {
        XCTAssertEqual(PageRequest.first, PageRequest(page: 0, size: 20))
    }

    func test_항목과_다음_요청이_같으면_같은_쪽() {
        let page = Page(items: [1, 2], next: PageRequest(page: 1, size: 20))

        XCTAssertEqual(page, Page(items: [1, 2], next: PageRequest(page: 1, size: 20)))
        XCTAssertNotEqual(page, Page(items: [1, 2], next: nil))
    }
}

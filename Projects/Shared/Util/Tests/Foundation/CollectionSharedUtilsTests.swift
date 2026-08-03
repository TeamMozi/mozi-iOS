import SharedUtils
import XCTest

final class CollectionSharedUtilsTests: XCTestCase {
    func test_safe_subscript() {
        let values = [10, 20]
        XCTAssertEqual(values[safe: 1], 20)
        XCTAssertNil(values[safe: 2])
    }

    func test_isNotEmpty() {
        XCTAssertTrue([1].isNotEmpty)
        XCTAssertFalse([Int]().isNotEmpty)
    }

    func test_chunked() {
        XCTAssertEqual([1, 2, 3, 4, 5].chunked(into: 2), [[1, 2], [3, 4], [5]])
        XCTAssertEqual([1, 2].chunked(into: 0), [])
    }
}

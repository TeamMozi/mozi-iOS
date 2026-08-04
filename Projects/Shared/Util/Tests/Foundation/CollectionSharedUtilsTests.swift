import SharedUtils
import XCTest

final class CollectionSharedUtilsTests: XCTestCase {
    func test_안전한_서브스크립트가_범위_밖이면_nil() {
        let values = [10, 20]
        XCTAssertEqual(values[safe: 1], 20)
        XCTAssertNil(values[safe: 2])
    }

    func test_비어있지_않으면_isNotEmpty_true() {
        XCTAssertTrue([1].isNotEmpty)
        XCTAssertFalse([Int]().isNotEmpty)
    }

    func test_청크_단위로_배열_분할() {
        XCTAssertEqual([1, 2, 3, 4, 5].chunked(into: 2), [[1, 2], [3, 4], [5]])
        XCTAssertEqual([1, 2].chunked(into: 0), [])
    }
}

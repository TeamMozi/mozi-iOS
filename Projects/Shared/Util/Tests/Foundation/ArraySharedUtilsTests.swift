import SharedUtils
import XCTest

private struct Item: Equatable {
    let id: Int
    let name: String
}

final class ArraySharedUtilsTests: XCTestCase {

    func test_청크_크기가_intMax여도_트랩하지_않음() {
        let values = [1, 2, 3]
        XCTAssertEqual(values.chunked(into: Int.max), [[1, 2, 3]])
    }

    func test_키_기준_중복_제거() {
        let items = [
            Item(id: 1, name: "a"),
            Item(id: 1, name: "b"),
            Item(id: 2, name: "c"),
        ]
        XCTAssertEqual(items.unique(by: \.id), [
            Item(id: 1, name: "a"),
            Item(id: 2, name: "c"),
        ])
    }

    func test_동일_요소_중복_제거() {
        XCTAssertEqual([1, 1, 2, 3, 2].removingDuplicates(), [1, 2, 3])
    }
}

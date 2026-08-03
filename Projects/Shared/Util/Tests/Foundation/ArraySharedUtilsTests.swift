import SharedUtils
import XCTest

private struct Item: Equatable {
    let id: Int
    let name: String
}

final class ArraySharedUtilsTests: XCTestCase {

    func test_chunked_into_intMax_doesNotTrap() {
        let values = [1, 2, 3]
        XCTAssertEqual(values.chunked(into: Int.max), [[1, 2, 3]])
    }

    func test_unique_by() {
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

    func test_removingDuplicates() {
        XCTAssertEqual([1, 1, 2, 3, 2].removingDuplicates(), [1, 2, 3])
    }
}

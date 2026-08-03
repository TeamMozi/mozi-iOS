import SharedUtils
import XCTest

private struct Item: Equatable {
    let id: Int
    let name: String
}

final class ArraySharedUtilsTests: XCTestCase {
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

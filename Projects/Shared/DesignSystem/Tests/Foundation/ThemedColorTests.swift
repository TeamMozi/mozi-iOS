@testable import SharedDesignSystem
import XCTest

final class ThemedColorTests: XCTestCase {
    func test_fixed_는_두_모드에_같은_색을_쓴다() {
        let theme = ThemedColor.fixed(PrimitiveColor.system.red)

        XCTAssertEqual(theme.dark, PrimitiveColor.system.red)
        XCTAssertEqual(theme.light, PrimitiveColor.system.red)
    }
}

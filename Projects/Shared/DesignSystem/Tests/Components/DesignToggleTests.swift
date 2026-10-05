@testable import SharedDesignSystem
import XCTest

final class DesignToggleTests: XCTestCase {
    func test_토글_켜짐_색은_두_모드_모두_원시_초록이다() {
        assertTheme(DesignTogglePalette.onTint, dark: 0x6CE582FF, light: 0x6CE582FF)
    }
}

@testable import SharedDesignSystem
import XCTest

final class DesignPickerCellTests: XCTestCase {
    func test_고르기_칸은_높이_36_모서리_6_좌우_14_간격_16_꺾쇠_14_Caption1_Regular다() {
        XCTAssertEqual(DesignPickerCellMetrics.height, 36)
        XCTAssertEqual(DesignPickerCellMetrics.cornerRadius, 6)
        XCTAssertEqual(DesignPickerCellMetrics.horizontalPadding, 14)
        XCTAssertEqual(DesignPickerCellMetrics.contentSpacing, 16)
        XCTAssertEqual(DesignPickerCellMetrics.chevronSize, 14)
        XCTAssertEqual(DesignPickerCellMetrics.textStyle, TextStyle.ds.caption1.regular)
    }

    func test_고르기_칸은_테두리_40_꺾쇠_subtle_값_primary_placeholder_tertiary다() {
        assertTheme(DesignPickerCellPalette.border, dark: 0x202027FF, light: 0xCACACEFF)
        XCTAssertEqual(DesignPickerCellPalette.chevron, SemanticColor.text.neutral.subtle)
        XCTAssertEqual(DesignPickerCellPalette.text(isEmpty: false), SemanticColor.text.neutral.primary)
        assertTheme(DesignPickerCellPalette.text(isEmpty: true), dark: 0xB0AFB5FF, light: 0x7A7887FF)
    }
}

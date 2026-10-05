@testable import SharedDesignSystem
import XCTest

final class DesignSearchFieldStyleTests: XCTestCase {
    func test_유리_알약형은_바탕이_없고_글자_placeholder_아이콘이_primary다() {
        let palette = DesignSearchFieldStyleResolver.palette(.glass)
        XCTAssertNil(palette.background, "바탕은 유리 효과다")
        assertTheme(palette.text, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        assertTheme(palette.placeholder, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        assertTheme(palette.icon, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
    }

    func test_납작형은_바탕_subtle에_placeholder_tertiary다() {
        let palette = DesignSearchFieldStyleResolver.palette(.flat)
        assertTheme(palette.background, dark: 0x18181CFF, light: 0xF2F2F3FF)
        assertTheme(palette.text, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        assertTheme(palette.placeholder, dark: 0xB0AFB5FF, light: 0x7A7887FF)
        assertTheme(palette.icon, dark: 0x7A7887FF, light: 0xB0AFB5FF)
    }

    func test_커서는_accent_default다() {
        assertTheme(DesignSearchFieldStyleResolver.cursor, dark: 0xFFF489FF, light: 0xF6BB09FF)
    }

    func test_유리_알약형은_높이_44_여백_12_간격_6_캡슐이다() {
        let metrics = DesignSearchFieldStyleResolver.metrics(.glass)
        XCTAssertEqual(metrics.height, 44)
        XCTAssertEqual(metrics.horizontalPadding, 12)
        XCTAssertEqual(metrics.spacing, 6)
        XCTAssertNil(metrics.cornerRadius)
    }

    func test_납작형은_높이_34_여백_12_간격_16_반경_4다() {
        let metrics = DesignSearchFieldStyleResolver.metrics(.flat)
        XCTAssertEqual(metrics.height, 34)
        XCTAssertEqual(metrics.horizontalPadding, 12)
        XCTAssertEqual(metrics.spacing, 16)
        XCTAssertEqual(metrics.cornerRadius, 4)
    }

    func test_검색_칸_아이콘은_18이다() {
        XCTAssertEqual(DesignSearchFieldMetrics.iconSize, 18)
    }
}

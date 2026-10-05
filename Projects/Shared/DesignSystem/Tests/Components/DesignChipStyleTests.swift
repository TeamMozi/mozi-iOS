@testable import SharedDesignSystem
import XCTest

final class DesignChipStyleTests: XCTestCase {
    func test_테두리형은_테두리_40과_글자_secondary다() {
        let palette = DesignChipStyleResolver.palette(style: .outlined, isEditing: false)
        XCTAssertNil(palette.background)
        assertTheme(palette.border, dark: 0x202027FF, light: 0xCACACEFF)
        assertTheme(palette.content, dark: 0xCACACEFF, light: 0x484753FF)
        assertTheme(palette.icon, dark: 0xCACACEFF, light: 0x484753FF)
    }

    func test_채움형은_바탕_vivid에_글자_neutral_1200과_검정_닫기다() {
        let palette = DesignChipStyleResolver.palette(style: .filled, isEditing: false)
        assertTheme(palette.background, dark: 0xF5FE76FF, light: 0xF6D631FF)
        XCTAssertNil(palette.border)
        assertTheme(palette.content, dark: 0x0E0E11FF, light: 0x0E0E11FF)
        assertTheme(palette.icon, dark: 0x000000FF, light: 0x000000FF)
    }

    func test_알약형_편집_중은_글자가_accent_highlight다() {
        let palette = DesignChipStyleResolver.palette(style: .pill, isEditing: true)
        assertTheme(palette.background, dark: 0x706D8266, light: 0xAFAFAF33)
        XCTAssertNil(palette.border)
        assertTheme(palette.content, dark: 0xF5FE76FF, light: 0xF29407FF)
    }

    func test_알약형_편집_중_아님은_글자가_tertiary다() {
        let palette = DesignChipStyleResolver.palette(style: .pill, isEditing: false)
        assertTheme(palette.background, dark: 0x706D8266, light: 0xAFAFAF33)
        assertTheme(palette.content, dark: 0xB0AFB5FF, light: 0x7A7887FF)
    }

    func test_테두리형과_채움형은_편집_중이_색을_바꾸지_않는다() {
        XCTAssertEqual(
            DesignChipStyleResolver.palette(style: .outlined, isEditing: true),
            DesignChipStyleResolver.palette(style: .outlined, isEditing: false)
        )
        XCTAssertEqual(
            DesignChipStyleResolver.palette(style: .filled, isEditing: true),
            DesignChipStyleResolver.palette(style: .filled, isEditing: false)
        )
    }

    func test_테두리형과_채움형은_Caption1_Medium에_여백_14다() {
        for style in [DesignChipStyle.outlined, .filled] {
            let metrics = DesignChipStyleResolver.metrics(style: style)
            XCTAssertEqual(metrics.textStyle, TextStyle.ds.caption1.medium)
            XCTAssertEqual(metrics.horizontalPadding, 14)
        }
    }

    func test_알약형은_Body_Regular에_여백_11이다() {
        let metrics = DesignChipStyleResolver.metrics(style: .pill)
        XCTAssertEqual(metrics.textStyle, TextStyle.ds.body.regular)
        XCTAssertEqual(metrics.horizontalPadding, 11)
    }

    func test_칩_높이_32_위아래_4_간격_4_닫기_14다() {
        XCTAssertEqual(DesignChipMetrics.height, 32)
        XCTAssertEqual(DesignChipMetrics.verticalPadding, 4)
        XCTAssertEqual(DesignChipMetrics.spacing, 4)
        XCTAssertEqual(DesignChipMetrics.closeIconSize, 14)
    }
}

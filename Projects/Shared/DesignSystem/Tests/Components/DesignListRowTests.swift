@testable import SharedDesignSystem
import XCTest

final class DesignListRowTests: XCTestCase {
    func test_기본_줄은_지금_모양이다() {
        let layout = DesignListRowLayout.of(.standard)
        XCTAssertEqual(layout.horizontalPadding, 16)
        XCTAssertEqual(layout.verticalPadding, 12)
        XCTAssertNil(layout.minHeight)
        XCTAssertEqual(layout.titleStyle, TextStyle.ds.body.semiBold)
        assertTheme(layout.titleColor, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        XCTAssertEqual(layout.subtitleStyle, TextStyle.ds.caption1.regular)
        assertTheme(layout.subtitleColor, dark: 0xB0AFB5FF, light: 0x7A7887FF)
        XCTAssertEqual(layout.textSpacing, 4)
        assertTheme(layout.selectedBackground, dark: 0x18181CFF, light: 0xF2F2F3FF)
    }

    /// 시안 `5068:94944`.
    func test_장소_줄은_좌우_20_위아래_10_높이_64_제목_headline_semiBold다() {
        let layout = DesignListRowLayout.of(.place)
        XCTAssertEqual(layout.horizontalPadding, 20)
        XCTAssertEqual(layout.verticalPadding, 10)
        XCTAssertEqual(layout.minHeight, 64)
        XCTAssertEqual(layout.titleStyle, TextStyle.ds.headline.semiBold)
        assertTheme(layout.titleColor, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        XCTAssertEqual(layout.subtitleStyle, TextStyle.ds.caption1.regular)
        assertTheme(layout.subtitleColor, dark: 0xB0AFB5FF, light: 0x7A7887FF)
        XCTAssertEqual(layout.textSpacing, 4)
        // 위아래 10 + 제목 22 + 간격 4 + 주소 18 + 10 = 64
        XCTAssertEqual(
            2 * layout.verticalPadding + layout.titleStyle.lineHeight + layout.textSpacing
                + layout.subtitleStyle.lineHeight,
            64
        )
    }

    /// 시안 `2891:164841`.
    func test_곡_줄은_좌우_20_위아래_12_높이_64_제목_14_18_secondary_보조_12_14_subtle이다() {
        let layout = DesignListRowLayout.of(.music)
        XCTAssertEqual(layout.horizontalPadding, 20)
        XCTAssertEqual(layout.verticalPadding, 12)
        XCTAssertEqual(layout.minHeight, 64)
        XCTAssertEqual(layout.titleStyle, TextStyle.ds.caption1.semiBold)
        assertTheme(layout.titleColor, dark: 0xCACACEFF, light: 0x484753FF)
        XCTAssertEqual(layout.subtitleStyle, TextStyle.ds.caption2.regular)
        assertTheme(layout.subtitleColor, dark: 0x7A7887FF, light: 0xB0AFB5FF)
        XCTAssertEqual(layout.textSpacing, 6)
        assertTheme(layout.selectedBackground, dark: 0xAFAFAF1A, light: 0xAFAFAF1A)
    }
}

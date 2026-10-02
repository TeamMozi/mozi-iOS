@testable import SharedDesignSystem
import XCTest

final class DesignButtonMetricsTests: XCTestCase {
    func test_버튼_크기별_높이_여백_모서리_아이콘이_정한_값이다() {
        XCTAssertEqual(DesignButtonSize.sm.height, 36)
        XCTAssertEqual(DesignButtonSize.sm.horizontalPadding, 12)
        XCTAssertEqual(DesignButtonSize.sm.cornerRadius, 4)
        XCTAssertEqual(DesignButtonSize.sm.iconSize, 14)

        XCTAssertEqual(DesignButtonSize.md.height, 40)
        XCTAssertEqual(DesignButtonSize.md.horizontalPadding, 16)
        XCTAssertEqual(DesignButtonSize.md.cornerRadius, 4)
        XCTAssertEqual(DesignButtonSize.md.iconSize, 16)

        XCTAssertEqual(DesignButtonSize.lg.height, 48)
        XCTAssertEqual(DesignButtonSize.lg.horizontalPadding, 20)
        XCTAssertEqual(DesignButtonSize.lg.cornerRadius, 8)
        XCTAssertEqual(DesignButtonSize.lg.iconSize, 18)
    }

    func test_버튼_크기별_글자는_가장_가까운_SemiBold_스타일이다() {
        XCTAssertEqual(DesignButtonSize.sm.textStyle.fontName, "Pretendard-SemiBold")
        XCTAssertEqual(DesignButtonSize.sm.textStyle.size, 14)
        XCTAssertEqual(DesignButtonSize.sm.textStyle.lineHeight, 18)

        XCTAssertEqual(DesignButtonSize.md.textStyle.fontName, "Pretendard-SemiBold")
        XCTAssertEqual(DesignButtonSize.md.textStyle.size, 16)
        XCTAssertEqual(DesignButtonSize.md.textStyle.lineHeight, 22)

        XCTAssertEqual(DesignButtonSize.lg.textStyle.fontName, "Pretendard-SemiBold")
        XCTAssertEqual(DesignButtonSize.lg.textStyle.size, 18)
        XCTAssertEqual(DesignButtonSize.lg.textStyle.lineHeight, 24)
    }

    func test_primary_비활성은_main_disabled_색이다() {
        let style = DesignButtonStyleResolver.resolve(variant: .primary, state: .disabled)
        assertTheme(style.background, dark: 0x18181CFF, light: 0xEAEAEBFF)
        assertTheme(style.content, dark: 0x7A7887FF, light: 0xB0AFB5FF)
        XCTAssertNil(style.border)
    }

    func test_secondary_기본은_neutral_default_색이다() {
        let style = DesignButtonStyleResolver.resolve(variant: .secondary, state: .default)
        assertTheme(style.background, dark: 0x202027FF, light: 0xF2F2F3FF)
        assertTheme(style.content, dark: 0xB0AFB5FF, light: 0x7A7887FF)
        XCTAssertNil(style.border)
    }

    func test_outlined_눌림은_ghost_pressed_색이고_테두리는_글자_색이다() {
        let style = DesignButtonStyleResolver.resolve(variant: .outlined, state: .pressed)
        assertTheme(style.background, dark: 0x18181CFF, light: 0xEAEAEBFF)
        assertTheme(style.content, dark: 0xFFF489FF, light: 0xF7CB3BFF)
        assertTheme(style.border, dark: 0xFFF489FF, light: 0xF7CB3BFF)
        XCTAssertEqual(style.borderWidth, 1)
    }

    func test_text_기본은_바탕이_투명하고_글자가_text_accent_색이다() {
        let style = DesignButtonStyleResolver.resolve(variant: .text, state: .default)
        assertTheme(style.background, dark: 0x00000000, light: 0xFAFAFA00)
        assertTheme(style.content, dark: 0xF5FE76FF, light: 0xF29407FF)
        XCTAssertNil(style.border)
    }

    func test_text_비활성은_글자가_text_neutral_색이다() {
        let style = DesignButtonStyleResolver.resolve(variant: .text, state: .disabled)
        assertTheme(style.content, dark: 0x7A7887FF, light: 0xB0AFB5FF)
    }

    func test_disabled_상태_해석() {
        // 부모 `.disabled` / `DesignButton(isEnabled: false)` 가 disabled 토큰을 쓰는지 검증한다.
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: false, isPressed: false),
            .disabled
        )
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: false, isPressed: true),
            .disabled
        )
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: true, isPressed: true),
            .pressed
        )
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: true, isPressed: false),
            .default
        )
    }
}

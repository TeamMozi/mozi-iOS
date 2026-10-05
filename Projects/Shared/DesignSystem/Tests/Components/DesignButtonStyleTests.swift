@testable import SharedDesignSystem
import SwiftUI
import XCTest

final class DesignButtonStyleTests: XCTestCase {
    func test_controlSize_mini와_small은_sm이다() {
        XCTAssertEqual(DesignButtonSize(.mini), .sm)
        XCTAssertEqual(DesignButtonSize(.small), .sm)
    }

    func test_controlSize_regular는_md다() {
        XCTAssertEqual(DesignButtonSize(.regular), .md)
    }

    func test_controlSize_large와_extraLarge는_lg다() {
        XCTAssertEqual(DesignButtonSize(.large), .lg)
        XCTAssertEqual(DesignButtonSize(.extraLarge), .lg)
    }

    func test_크기별_높이_여백_반경_아이콘이_Figma_값이다() {
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

    func test_세_크기_아이콘_간격과_글자가_같다() {
        for size in [DesignButtonSize.sm, .md, .lg] {
            XCTAssertEqual(size.iconSpacing, 8)
            XCTAssertEqual(size.textStyle, TextStyle.ds.headline.semiBold)
        }
    }

    func test_main_상태별_색이_button_main_색이다() {
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .main, state: .default),
            background: (dark: 0xFFF489FF, light: 0xFFF489FF),
            content: (dark: 0x0E0E11FF, light: 0x0E0E11FF)
        )
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .main, state: .pressed),
            background: (dark: 0xF7CB3BFF, light: 0xF7CB3BFF),
            content: (dark: 0x0E0E11FF, light: 0x0E0E11FF)
        )
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .main, state: .disabled),
            background: (dark: 0x18181CFF, light: 0xEAEAEBFF),
            content: (dark: 0x7A7887FF, light: 0xB0AFB5FF)
        )
    }

    func test_neutral_상태별_색이_button_neutral_색이다() {
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .neutral, state: .default),
            background: (dark: 0x202027FF, light: 0xF2F2F3FF),
            content: (dark: 0xB0AFB5FF, light: 0x7A7887FF)
        )
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .neutral, state: .pressed),
            background: (dark: 0x18181CFF, light: 0xD5D5DFFF),
            content: (dark: 0xB0AFB5FF, light: 0x7A7887FF)
        )
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .neutral, state: .disabled),
            background: (dark: 0x18181CFF, light: 0xEAEAEBFF),
            content: (dark: 0x7A7887FF, light: 0xB0AFB5FF)
        )
    }

    func test_ghost_상태별_색이_button_ghost_색이다() {
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .ghost, state: .default),
            background: (dark: 0x000000FF, light: 0xFCFCFCFF),
            content: (dark: 0xFFF489FF, light: 0xF7CB3BFF)
        )
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .ghost, state: .pressed),
            background: (dark: 0x18181CFF, light: 0xEAEAEBFF),
            content: (dark: 0xFFF489FF, light: 0xF7CB3BFF)
        )
        assertPalette(
            DesignButtonStyleResolver.palette(kind: .ghost, state: .disabled),
            background: (dark: 0x000000FF, light: 0xFCFCFCFF),
            content: (dark: 0x7A7887FF, light: 0xB0AFB5FF)
        )
    }

    @MainActor
    func test_짧은_이름이_계열을_고른다() {
        XCTAssertEqual(DesignButtonStyle.main.kind, .main)
        XCTAssertEqual(DesignButtonStyle.neutral.kind, .neutral)
        XCTAssertEqual(DesignButtonStyle.ghost.kind, .ghost)
    }
}

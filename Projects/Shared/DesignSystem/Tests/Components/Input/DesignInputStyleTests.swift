@testable import SharedDesignSystem
import UIKit
import XCTest

final class DesignInputStyleTests: XCTestCase {
    func test_입력_중은_값과_상관없이_포커스로_정해진다() {
        XCTAssertEqual(DesignInputPhase(isEditing: true, isEmpty: true), .editing)
        XCTAssertEqual(DesignInputPhase(isEditing: true, isEmpty: false), .editing)
    }

    func test_포커스가_없으면_값의_유무로_입력_전과_뒤를_가른다() {
        XCTAssertEqual(DesignInputPhase(isEditing: false, isEmpty: true), .empty)
        XCTAssertEqual(DesignInputPhase(isEditing: false, isEmpty: false), .filled)
    }

    func test_입력_전_칸은_테두리_20과_placeholder_subtle이다() {
        let palette = DesignInputStyleResolver.field(.empty)
        assertTheme(palette.border, dark: 0x34333EFF, light: 0xD5D5DFFF)
        assertTheme(palette.background, dark: 0x000000FF, light: 0xFCFCFCFF)
        assertTheme(palette.placeholder, dark: 0x7A7887FF, light: 0xB0AFB5FF)
    }

    func test_입력_중_칸은_테두리_50과_글자_primary다() {
        let palette = DesignInputStyleResolver.field(.editing)
        assertTheme(palette.border, dark: 0x7A7887FF, light: 0x484753FF)
        assertTheme(palette.background, dark: 0x000000FF, light: 0xFCFCFCFF)
        assertTheme(palette.text, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        assertTheme(palette.placeholder, dark: 0x7A7887FF, light: 0xB0AFB5FF)
    }

    func test_입력_뒤_칸은_테두리_20과_글자_secondary다() {
        let palette = DesignInputStyleResolver.field(.filled)
        assertTheme(palette.border, dark: 0x34333EFF, light: 0xD5D5DFFF)
        assertTheme(palette.text, dark: 0xCACACEFF, light: 0x484753FF)
    }

    func test_캡션_칸은_테두리와_바탕이_없고_placeholder가_tertiary다() {
        let palette = DesignInputStyleResolver.caption
        XCTAssertNil(palette.border)
        XCTAssertNil(palette.background)
        assertTheme(palette.text, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        assertTheme(palette.placeholder, dark: 0xB0AFB5FF, light: 0x7A7887FF)
    }

    func test_라벨_필수_커서_글자수_꺾쇠_색이_시안_값이다() {
        assertTheme(DesignInputStyleResolver.label, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        assertTheme(DesignInputStyleResolver.required, dark: 0xFF5F57FF, light: 0xFF5F57FF)
        assertTheme(DesignInputStyleResolver.tint, dark: 0xFFF489FF, light: 0xF6BB09FF)
        assertTheme(DesignInputStyleResolver.counter, dark: 0x484753FF, light: 0xCACACEFF)
        assertTheme(DesignInputStyleResolver.chevron, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
    }

    func test_입력_칸_치수가_시안_값이다() {
        XCTAssertEqual(DesignInputMetrics.fieldHeight, 46)
        XCTAssertEqual(DesignInputMetrics.labelSpacing, 10)
        XCTAssertEqual(DesignInputMetrics.cellSpacing, 6)
        XCTAssertEqual(DesignInputMetrics.cellContentSpacing, 6)
        XCTAssertEqual(DesignInputMetrics.horizontalPadding, 12)
        XCTAssertEqual(DesignInputMetrics.chevronSize, 18)
        XCTAssertEqual(DesignInputMetrics.cornerRadius, 8)
    }

    func test_여러_줄_칸은_높이_113과_글자_둘레가_시안_값이다() {
        let layout = DesignTextAreaLayout.of(.standard)
        XCTAssertEqual(layout.height, 113)
        XCTAssertEqual(layout.textInsets, UIEdgeInsets(top: 11, left: 12, bottom: 28, right: 12))
        XCTAssertEqual(layout.textStyle, TextStyle.ds.body.regular)
        XCTAssertEqual(layout.placeholderStyle, TextStyle.ds.body.regular)
        XCTAssertEqual(layout.counterTrailing, 12)
        XCTAssertEqual(layout.counterBottom, 14)
    }

    func test_캡션_칸은_높이_127과_글자_둘레가_시안_값이다() {
        let layout = DesignTextAreaLayout.of(.caption)
        XCTAssertEqual(layout.height, 127)
        XCTAssertEqual(layout.textInsets, UIEdgeInsets(top: 12, left: 16, bottom: 34, right: 16))
        XCTAssertEqual(layout.textStyle, TextStyle.ds.subtext.regular)
        XCTAssertEqual(layout.placeholderStyle, TextStyle.ds.subtext.regular)
        XCTAssertEqual(layout.counterTrailing, 8)
        XCTAssertEqual(layout.counterBottom, 14)
    }

    func test_드롭다운_칸은_값이_없으면_입력_전_있으면_입력_뒤_색이다() {
        let empty = DesignDropdownCell(value: nil, placeholder: "년", options: ["2000년"]) { _ in }
        let filled = DesignDropdownCell(value: "2000년", placeholder: "년", options: ["2000년"]) { _ in }
        XCTAssertEqual(empty.palette, DesignInputStyleResolver.field(.empty))
        XCTAssertEqual(filled.palette, DesignInputStyleResolver.field(.filled))
        XCTAssertNotEqual(filled.palette, DesignInputStyleResolver.field(.editing))
    }

    func test_필수_표시는_Medium_16_줄_20_자간_2퍼센트다() {
        let style = DesignInputMetrics.requiredMarkStyle
        XCTAssertEqual(style.fontName, "Pretendard-Medium")
        XCTAssertEqual(style.size, 16)
        XCTAssertEqual(style.lineHeight, 20)
        XCTAssertEqual(style.letterSpacingEm, 0.02)
    }
}

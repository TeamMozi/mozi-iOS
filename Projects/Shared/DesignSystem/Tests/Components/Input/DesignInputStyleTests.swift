@testable import SharedDesignSystem
import SwiftUI
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

    func test_줄_칸은_테두리와_바탕이_없고_placeholder가_subtle이다() {
        for phase in [DesignInputPhase.empty, .editing, .filled] {
            let palette = DesignInputStyleResolver.row(phase)
            XCTAssertNil(palette.border)
            XCTAssertNil(palette.background)
            assertTheme(palette.placeholder, dark: 0x7A7887FF, light: 0xB0AFB5FF)
        }
        XCTAssertEqual(DesignInputStyleResolver.row(.editing).text, DesignInputStyleResolver.field(.editing).text)
        XCTAssertEqual(DesignInputStyleResolver.row(.filled).text, DesignInputStyleResolver.field(.filled).text)
    }

    func test_한_줄_칸은_기본_높이_46_좌우_12다() {
        let layout = DesignTextFieldLayout.of(.standard)
        XCTAssertEqual(layout.height, 46)
        XCTAssertEqual(layout.horizontalPadding, 12)
    }

    func test_한_줄_줄_칸은_높이_54_좌우_16이다() {
        let layout = DesignTextFieldLayout.of(.row)
        XCTAssertEqual(layout.height, 54)
        XCTAssertEqual(layout.horizontalPadding, 16)
    }

    func test_상자_여러_줄_칸은_글자_수를_그린다() {
        XCTAssertTrue(DesignTextAreaLayout.of(.standard).showsCounter)
        XCTAssertTrue(DesignTextAreaLayout.of(.caption).showsCounter)
    }

    func test_여러_줄_줄_칸은_받은_높이에_위아래_10_좌우_16이고_글자_수가_없다() {
        let layout = DesignTextAreaLayout.of(.row(height: 116, showsCounter: false))
        XCTAssertEqual(layout.height, 116)
        XCTAssertEqual(layout.textInsets, UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        XCTAssertEqual(layout.textStyle, TextStyle.ds.body.regular)
        XCTAssertEqual(layout.placeholderStyle, TextStyle.ds.body.regular)
        XCTAssertFalse(layout.showsCounter)
    }

    func test_여러_줄_줄_칸에_글자_수를_켜면_오른쪽_16_아래_10에_두고_글자_둘레가_비켜_간다() {
        let layout = DesignTextAreaLayout.of(.row(height: 304, showsCounter: true))
        XCTAssertEqual(layout.height, 304)
        XCTAssertEqual(layout.textInsets, UIEdgeInsets(top: 10, left: 16, bottom: 24, right: 16))
        XCTAssertTrue(layout.showsCounter)
        XCTAssertEqual(layout.counterTrailing, 16)
        XCTAssertEqual(layout.counterBottom, 10)
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

    // MARK: 줄 칸 글자 모양·색

    /// 시안 채운 모임 이름 SemiBold 20/28 −2% primary, 상세 글·placeholder Regular 16/26 −2% tertiary.
    private let nameText = DesignRowText(
        textStyle: TextStyle.ds.pretendard(.semiBold, size: 20, lineHeight: 28, letterSpacingEm: -0.02),
        textColor: Color.ds.text.neutral.primary,
        placeholderStyle: TextStyle.ds.pretendard(.regular, size: 16, lineHeight: 26, letterSpacingEm: -0.02),
        placeholderColor: Color.ds.text.neutral.tertiary
    )

    func test_줄_칸_글자_모양을_비우면_지금처럼_Body_Regular다() {
        XCTAssertEqual(DesignRowText.standard.textStyle, TextStyle.ds.body.regular)
        XCTAssertEqual(DesignRowText.standard.placeholderStyle, TextStyle.ds.body.regular)
        XCTAssertNil(DesignRowText.standard.textColor)
        XCTAssertNil(DesignRowText.standard.placeholderColor)
        XCTAssertEqual(DesignTextFieldStyle.row, DesignTextFieldStyle.row(text: .standard))
        XCTAssertEqual(
            DesignTextAreaStyle.row(height: 100, showsCounter: false),
            DesignTextAreaStyle.row(height: 100, showsCounter: false, text: .standard)
        )
    }

    func test_한_줄_칸의_글자_모양은_기본이_Body_Regular다() {
        for style in [DesignTextFieldStyle.standard, .row] {
            let layout = DesignTextFieldLayout.of(style)
            XCTAssertEqual(layout.textStyle, TextStyle.ds.body.regular)
            XCTAssertEqual(layout.placeholderStyle, TextStyle.ds.body.regular)
        }
    }

    func test_한_줄_줄_칸에_넘긴_글자_모양은_입력_글자와_placeholder_에_따로_걸린다() {
        let layout = DesignTextFieldLayout.of(.row(text: nameText))
        XCTAssertEqual(layout.height, 54)
        XCTAssertEqual(layout.horizontalPadding, 16)
        XCTAssertEqual(layout.textStyle.fontName, "Pretendard-SemiBold")
        XCTAssertEqual(layout.textStyle.size, 20)
        XCTAssertEqual(layout.textStyle.lineHeight, 28)
        XCTAssertEqual(layout.placeholderStyle.fontName, "Pretendard-Regular")
        XCTAssertEqual(layout.placeholderStyle.size, 16)
        XCTAssertEqual(layout.placeholderStyle.lineHeight, 26)
    }

    func test_여러_줄_줄_칸에_넘긴_글자_모양은_치수를_바꾸지_않고_글자에만_걸린다() {
        let detail = DesignRowText(
            textStyle: TextStyle.ds.pretendard(.regular, size: 16, lineHeight: 26, letterSpacingEm: -0.02),
            placeholderStyle: TextStyle.ds.pretendard(.regular, size: 16, lineHeight: 26, letterSpacingEm: -0.02),
            placeholderColor: Color.ds.text.neutral.tertiary
        )
        let layout = DesignTextAreaLayout.of(.row(height: 304, showsCounter: true, text: detail))
        XCTAssertEqual(layout.height, 304)
        XCTAssertEqual(layout.textInsets, UIEdgeInsets(top: 10, left: 16, bottom: 24, right: 16))
        XCTAssertEqual(layout.textStyle, detail.textStyle)
        XCTAssertEqual(layout.placeholderStyle, detail.placeholderStyle)
    }

    @MainActor
    func test_줄_칸_색을_넘기면_상태와_상관없이_그_색이다() {
        for phase in [DesignInputPhase.empty, .editing, .filled] {
            let palette = DesignInputStyleResolver.row(phase)
            let text = nameText.textColor(fallback: palette.text)
            let placeholder = nameText.placeholderColor(fallback: palette.placeholder)
            XCTAssertEqual(rgba(text.uiColor, in: .dark), 0xFCFCFCFF)
            XCTAssertEqual(rgba(text.uiColor, in: .light), 0x0E0E11FF)
            XCTAssertEqual(rgba(placeholder.uiColor, in: .dark), 0xB0AFB5FF)
            XCTAssertEqual(rgba(placeholder.uiColor, in: .light), 0x7A7887FF)
        }
    }

    @MainActor
    func test_줄_칸_색을_비우면_상태별_지금_색이다() {
        let filled = DesignInputStyleResolver.row(.filled)
        let text = DesignRowText.standard.textColor(fallback: filled.text)
        let placeholder = DesignRowText.standard.placeholderColor(fallback: filled.placeholder)
        XCTAssertEqual(rgba(text.uiColor, in: .dark), 0xCACACEFF)
        XCTAssertEqual(rgba(text.uiColor, in: .light), 0x484753FF)
        XCTAssertEqual(rgba(placeholder.uiColor, in: .dark), 0x7A7887FF)
        XCTAssertEqual(rgba(placeholder.uiColor, in: .light), 0xB0AFB5FF)
    }
}

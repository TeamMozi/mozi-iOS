import SwiftUI
import XCTest
@testable import SharedDesignSystem

final class TypographyTests: XCTestCase {
    func test_body_small14_regular_메트릭스() {
        let style = TextStyle.ds.body.small14Regular
        XCTAssertEqual(style.size, 14)
        XCTAssertEqual(style.lineHeight, 24)
        XCTAssertEqual(style.letterSpacingEm, 0)
        XCTAssertEqual(style.fontName, "Pretendard-Regular")
    }

    func test_heading_large32_bold_메트릭스() {
        let style = TextStyle.ds.heading.large32Bold
        XCTAssertEqual(style.size, 32)
        XCTAssertEqual(style.lineHeight, 40)
        XCTAssertEqual(style.letterSpacingEm, -0.01, accuracy: 0.0001)
        XCTAssertEqual(style.fontName, "Pretendard-Bold")
    }

    func test_button_sm14가_semibold() {
        let style = TextStyle.ds.button.sm14Semibold
        XCTAssertEqual(style.size, 14)
        XCTAssertEqual(style.lineHeight, 14)
        XCTAssertEqual(style.fontName, "Pretendard-SemiBold")
    }

    func test_label_자간_값() {
        XCTAssertEqual(TextStyle.ds.label.small12Medium.letterSpacingEm, 0.02, accuracy: 0.0001)
    }

    func test_heading_title_전체_표() {
        assertStyle(
            TextStyle.ds.heading.large32Bold,
            fontName: "Pretendard-Bold",
            size: 32,
            lineHeight: 40,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.heading.large32Semibold,
            fontName: "Pretendard-SemiBold",
            size: 32,
            lineHeight: 40,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.heading.medium28Bold,
            fontName: "Pretendard-Bold",
            size: 28,
            lineHeight: 36,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.heading.medium28Semibold,
            fontName: "Pretendard-SemiBold",
            size: 28,
            lineHeight: 36,
            letterSpacingEm: -0.01
        )

        assertStyle(
            TextStyle.ds.title.large24Bold,
            fontName: "Pretendard-Bold",
            size: 24,
            lineHeight: 32,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.title.large24Semibold,
            fontName: "Pretendard-SemiBold",
            size: 24,
            lineHeight: 32,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.title.medium22Bold,
            fontName: "Pretendard-Bold",
            size: 22,
            lineHeight: 30,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.title.medium22Semibold,
            fontName: "Pretendard-SemiBold",
            size: 22,
            lineHeight: 30,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.title.small20Bold,
            fontName: "Pretendard-Bold",
            size: 20,
            lineHeight: 28,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.title.small20Semibold,
            fontName: "Pretendard-SemiBold",
            size: 20,
            lineHeight: 28,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.title.xsmall18Bold,
            fontName: "Pretendard-Bold",
            size: 18,
            lineHeight: 26,
            letterSpacingEm: -0.01
        )
        assertStyle(
            TextStyle.ds.title.xsmall18Semibold,
            fontName: "Pretendard-SemiBold",
            size: 18,
            lineHeight: 26,
            letterSpacingEm: -0.01
        )
    }

    func test_body_label_button_전체_표() {
        assertStyle(
            TextStyle.ds.body.large18Semibold,
            fontName: "Pretendard-SemiBold",
            size: 18,
            lineHeight: 30,
            letterSpacingEm: 0
        )
        assertStyle(
            TextStyle.ds.body.large18Regular,
            fontName: "Pretendard-Regular",
            size: 18,
            lineHeight: 30,
            letterSpacingEm: 0
        )
        assertStyle(
            TextStyle.ds.body.medium16Semibold,
            fontName: "Pretendard-SemiBold",
            size: 16,
            lineHeight: 28,
            letterSpacingEm: 0
        )
        assertStyle(
            TextStyle.ds.body.medium16Regular,
            fontName: "Pretendard-Regular",
            size: 16,
            lineHeight: 28,
            letterSpacingEm: 0
        )
        assertStyle(
            TextStyle.ds.body.small14Semibold,
            fontName: "Pretendard-SemiBold",
            size: 14,
            lineHeight: 24,
            letterSpacingEm: 0
        )
        assertStyle(
            TextStyle.ds.body.small14Regular,
            fontName: "Pretendard-Regular",
            size: 14,
            lineHeight: 24,
            letterSpacingEm: 0
        )

        assertStyle(
            TextStyle.ds.label.large16Medium,
            fontName: "Pretendard-Medium",
            size: 16,
            lineHeight: 20,
            letterSpacingEm: 0.02
        )
        assertStyle(
            TextStyle.ds.label.medium14Medium,
            fontName: "Pretendard-Medium",
            size: 14,
            lineHeight: 20,
            letterSpacingEm: 0.02
        )
        assertStyle(
            TextStyle.ds.label.small12Medium,
            fontName: "Pretendard-Medium",
            size: 12,
            lineHeight: 16,
            letterSpacingEm: 0.02
        )

        assertStyle(
            TextStyle.ds.button.sm14Semibold,
            fontName: "Pretendard-SemiBold",
            size: 14,
            lineHeight: 14,
            letterSpacingEm: 0
        )
        assertStyle(
            TextStyle.ds.button.md16Semibold,
            fontName: "Pretendard-SemiBold",
            size: 16,
            lineHeight: 16,
            letterSpacingEm: 0
        )
        assertStyle(
            TextStyle.ds.button.lg18Semibold,
            fontName: "Pretendard-SemiBold",
            size: 18,
            lineHeight: 18,
            letterSpacingEm: 0
        )
    }

    func test_파생_spacing_헬퍼_값() {
        let heading = TextStyle.ds.heading.large32Bold
        XCTAssertEqual(heading.letterSpacing, 32 * -0.01, accuracy: 0.0001)
        XCTAssertEqual(heading.additionalLineSpacing, 8)

        let button = TextStyle.ds.button.sm14Semibold
        XCTAssertEqual(button.letterSpacing, 0)
        XCTAssertEqual(button.additionalLineSpacing, 0)

        let label = TextStyle.ds.label.small12Medium
        XCTAssertEqual(label.letterSpacing, 12 * 0.02, accuracy: 0.0001)
        XCTAssertEqual(label.additionalLineSpacing, 4)
    }

    func test_공개_Font_ds_경로가_해석됨() {
        XCTAssertNotNil(Font.ds.heading.large32Bold)
        XCTAssertNotNil(Font.ds.title.xsmall18Semibold)
        XCTAssertNotNil(Font.ds.body.small14Regular)
        XCTAssertNotNil(Font.ds.label.medium14Medium)
        XCTAssertNotNil(Font.ds.button.lg18Semibold)
    }

    private func assertStyle(
        _ style: TextStyle,
        fontName: String,
        size: CGFloat,
        lineHeight: CGFloat,
        letterSpacingEm: CGFloat,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(style.fontName, fontName, file: file, line: line)
        XCTAssertEqual(style.size, size, file: file, line: line)
        XCTAssertEqual(style.lineHeight, lineHeight, file: file, line: line)
        XCTAssertEqual(style.letterSpacingEm, letterSpacingEm, accuracy: 0.0001, file: file, line: line)
    }
}

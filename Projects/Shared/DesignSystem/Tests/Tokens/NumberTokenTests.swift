import SharedDesignSystem
import XCTest

final class NumberTokenTests: XCTestCase {
    func test_radius_9개_값이_Figma_표와_같다() {
        let radius = CGFloat.ds.radius
        XCTAssertEqual(radius.none, 0)
        XCTAssertEqual(radius._4, 4)
        XCTAssertEqual(radius._6, 6)
        XCTAssertEqual(radius._8, 8)
        XCTAssertEqual(radius._10, 10)
        XCTAssertEqual(radius._12, 12)
        XCTAssertEqual(radius._16, 16)
        XCTAssertEqual(radius._24, 24)
        XCTAssertEqual(radius.full, 9999)
    }

    func test_spacing_6개_값이_Figma_표와_같다() {
        let spacing = CGFloat.ds.spacing
        XCTAssertEqual(spacing.xs, 4)
        XCTAssertEqual(spacing.sm, 8)
        XCTAssertEqual(spacing.md, 12)
        XCTAssertEqual(spacing.lg, 16)
        XCTAssertEqual(spacing.xl, 24)
        XCTAssertEqual(spacing.xxl, 32)
    }

    func test_border_2개_값이_Figma_표와_같다() {
        XCTAssertEqual(CGFloat.ds.border.thin, 1)
        XCTAssertEqual(CGFloat.ds.border.thick, 2)
    }

    func test_buttonHeight_3개_값이_Figma_표와_같다() {
        XCTAssertEqual(CGFloat.ds.buttonHeight.controlSm, 36)
        XCTAssertEqual(CGFloat.ds.buttonHeight.controlMd, 40)
        XCTAssertEqual(CGFloat.ds.buttonHeight.controlLg, 48)
    }

    func test_iconSize_4개_값이_Figma_표와_같다() {
        XCTAssertEqual(CGFloat.ds.iconSize._14, 14)
        XCTAssertEqual(CGFloat.ds.iconSize._18, 18)
        XCTAssertEqual(CGFloat.ds.iconSize._24, 24)
        XCTAssertEqual(CGFloat.ds.iconSize._28, 28)
    }

    func test_layout_margin이_그리드_바깥_여백_16이다() {
        XCTAssertEqual(CGFloat.ds.layout.margin, 16)
    }
}

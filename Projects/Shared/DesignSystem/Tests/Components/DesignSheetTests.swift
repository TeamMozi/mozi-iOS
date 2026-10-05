@testable import SharedDesignSystem
import SwiftUI
import XCTest

final class DesignSheetTests: XCTestCase {
    func test_시트_딤은_overlay_gray_default_다크_706D82_40퍼센트_라이트_AFAFAF_20퍼센트다() {
        XCTAssertEqual(DesignSheetMetrics.dim, SemanticColor.overlay.gray.default)
        assertTheme(DesignSheetMetrics.dim, dark: 0x706D8266, light: 0xAFAFAF33)
    }

    func test_시트_몸통은_fill_neutral_default로_불투명하다() {
        XCTAssertEqual(DesignSheetMetrics.background, SemanticColor.fill.neutral.default)
        assertTheme(DesignSheetMetrics.background, dark: 0x000000FF, light: 0xFCFCFCFF)
    }

    func test_medium과_large가_있으면_시스템_딤_끄는_상한은_large다() {
        XCTAssertEqual(DesignSheetMetrics.largestDetent(in: [.medium, .large]), .large)
        XCTAssertEqual(DesignSheetMetrics.largestDetent(in: [.large, .medium]), .large)
    }

    func test_medium만_있으면_상한은_medium이다() {
        XCTAssertEqual(DesignSheetMetrics.largestDetent(in: [.medium]), .medium)
    }

    func test_고정_높이만_있으면_상한은_그_높이다() {
        XCTAssertEqual(DesignSheetMetrics.largestDetent(in: [.height(266)]), .height(266))
    }

    func test_large가_없으면_배열의_마지막을_상한으로_받는다() {
        XCTAssertEqual(DesignSheetMetrics.largestDetent(in: [.height(266), .medium]), .medium)
    }

    func test_높이가_없으면_시스템_기본인_large만_쓴다() {
        XCTAssertEqual(DesignSheetMetrics.detents(from: []), [.large])
        XCTAssertEqual(DesignSheetMetrics.largestDetent(in: []), .large)
    }

    func test_시트가_자리_잡은_높이에_있으면_딤은_다_짙다() {
        XCTAssertEqual(DesignSheetMetrics.dimOpacity(sheetTop: 393, restingTop: 393, containerHeight: 844), 1)
    }

    func test_자리_잡은_높이보다_위에_있으면_딤은_다_짙다() {
        XCTAssertEqual(DesignSheetMetrics.dimOpacity(sheetTop: 47, restingTop: 393, containerHeight: 844), 1)
    }

    func test_자리_잡은_높이와_화면_아래_끝_사이에서는_내려간_만큼_옅어진다() {
        let half = DesignSheetMetrics.dimOpacity(sheetTop: 618.5, restingTop: 393, containerHeight: 844)
        let quarter = DesignSheetMetrics.dimOpacity(sheetTop: 731.25, restingTop: 393, containerHeight: 844)
        XCTAssertEqual(half, 0.5, accuracy: 0.0001)
        XCTAssertEqual(quarter, 0.25, accuracy: 0.0001)
    }

    func test_시트_위_끝이_화면_아래_끝에_닿거나_넘으면_딤은_0이다() {
        XCTAssertEqual(DesignSheetMetrics.dimOpacity(sheetTop: 844, restingTop: 393, containerHeight: 844), 0)
        XCTAssertEqual(DesignSheetMetrics.dimOpacity(sheetTop: 854, restingTop: 393, containerHeight: 844), 0)
    }

    func test_자리_잡은_높이가_화면_아래_끝_밖이면_화면_안에_있을_때만_짙다() {
        XCTAssertEqual(DesignSheetMetrics.dimOpacity(sheetTop: 800, restingTop: 854, containerHeight: 844), 1)
        XCTAssertEqual(DesignSheetMetrics.dimOpacity(sheetTop: 854, restingTop: 854, containerHeight: 844), 0)
    }

    func test_닫는_중이면_여는_중이어도_닫기_단계다() {
        XCTAssertEqual(DesignSheetPhase(isBeingPresented: true, isBeingDismissed: true), .dismissing)
        XCTAssertEqual(DesignSheetPhase(isBeingPresented: false, isBeingDismissed: true), .dismissing)
        XCTAssertEqual(DesignSheetPhase(isBeingPresented: true, isBeingDismissed: false), .presenting)
        XCTAssertEqual(DesignSheetPhase(isBeingPresented: false, isBeingDismissed: false), .shown)
    }

    func test_여는_중이면_올라갈_자리를_기준으로_올라온_만큼_짙어진다() {
        let opacity = DesignSheetMetrics.dimOpacity(
            phase: .presenting, shownTop: 618.5, targetTop: 393, restingTop: nil, containerHeight: 844
        )
        XCTAssertEqual(opacity, 0.5, accuracy: 0.0001)
    }

    func test_떠_있는_동안은_높이_사이를_움직여도_다_짙다() {
        let opacity = DesignSheetMetrics.dimOpacity(
            phase: .shown, shownTop: 300, targetTop: 47, restingTop: 393, containerHeight: 844
        )
        XCTAssertEqual(opacity, 1)
    }

    func test_닫는_중이면_닫기_직전에_자리_잡은_높이를_기준으로_옅어진다() {
        let opacity = DesignSheetMetrics.dimOpacity(
            phase: .dismissing, shownTop: 618.5, targetTop: 854, restingTop: 393, containerHeight: 844
        )
        XCTAssertEqual(opacity, 0.5, accuracy: 0.0001)
    }

    func test_닫기_직전_높이를_모르면_움직이는_목표를_기준으로_쓴다() {
        let opacity = DesignSheetMetrics.dimOpacity(
            phase: .dismissing, shownTop: 618.5, targetTop: 393, restingTop: nil, containerHeight: 844
        )
        XCTAssertEqual(opacity, 0.5, accuracy: 0.0001)
    }

    func test_닫는_중에는_기준_높이를_바꾸지_않는다() {
        XCTAssertEqual(DesignSheetMetrics.restingTop(phase: .dismissing, targetTop: 600, previous: 393), 393)
    }

    func test_처음_뜰_때는_올라갈_자리가_기준_높이다() {
        XCTAssertEqual(DesignSheetMetrics.restingTop(phase: .presenting, targetTop: 393, previous: nil), 393)
    }

    func test_떠_있는_동안_위로_올라가도_기준은_가장_낮은_자리를_지킨다() {
        XCTAssertEqual(DesignSheetMetrics.restingTop(phase: .shown, targetTop: 47, previous: 393), 393)
        XCTAssertEqual(DesignSheetMetrics.restingTop(phase: .shown, targetTop: 361, previous: 393), 393)
    }

    func test_떠_있는_동안_더_낮은_자리에_서면_기준이_그리로_내려간다() {
        XCTAssertEqual(DesignSheetMetrics.restingTop(phase: .shown, targetTop: 548, previous: 393), 548)
    }

    func test_떠_있고_멈춰_있을_때만_화면_주사율을_낮춘다() {
        XCTAssertFalse(DesignSheetMetrics.needsEveryFrame(phase: .shown, shownTop: 393, targetTop: 393))
        XCTAssertTrue(DesignSheetMetrics.needsEveryFrame(phase: .shown, shownTop: 300, targetTop: 393))
        XCTAssertTrue(DesignSheetMetrics.needsEveryFrame(phase: .presenting, shownTop: 393, targetTop: 393))
        XCTAssertTrue(DesignSheetMetrics.needsEveryFrame(phase: .dismissing, shownTop: 600, targetTop: 600))
    }
}

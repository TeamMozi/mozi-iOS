@testable import SharedDesignSystem
import XCTest

/// 시안 Form Group 과 Row 의 Separator.
final class DesignFormGroupTests: XCTestCase {
    func test_칸_묶음은_모서리_26_안쪽_여백_0_줄_사이_간격_0이다() {
        XCTAssertEqual(DesignFormGroupMetrics.cornerRadius, 26)
        XCTAssertEqual(DesignFormGroupMetrics.padding, 0)
        XCTAssertEqual(DesignFormGroupMetrics.spacing, 0)
    }

    func test_칸_묶음_채움은_두_모드에서_overlay_gray_10이다() {
        assertTheme(DesignFormGroupMetrics.fill, dark: 0xAFAFAF1A, light: 0xAFAFAF1A)
    }

    func test_줄_구분선은_왼쪽_14_오른쪽_16_들여_두께_1이다() {
        XCTAssertEqual(DesignFormRowSeparatorMetrics.leadingInset, 14)
        XCTAssertEqual(DesignFormRowSeparatorMetrics.trailingInset, 16)
        XCTAssertEqual(DesignFormRowSeparatorMetrics.thickness, 1)
    }

    func test_줄_구분선_색은_border_neutral_30이다() {
        XCTAssertEqual(DesignFormRowSeparatorMetrics.color, SemanticColor.border.neutral._30)
    }

    /// 칸 묶음 너비 343 에서 구분선 길이는 343 - 14 - 16 = 313.
    func test_구분선_길이는_칸_너비에서_좌우_들여씀을_뺀_값이다() {
        XCTAssertEqual(DesignFormRowSeparatorMetrics.length(in: 343), 313)
        XCTAssertEqual(DesignFormRowSeparatorMetrics.length(in: 20), 0)
    }
}

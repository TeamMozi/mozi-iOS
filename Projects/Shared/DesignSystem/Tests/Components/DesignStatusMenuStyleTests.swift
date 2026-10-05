@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

final class DesignStatusMenuStyleTests: XCTestCase {
    func test_항목은_모집_중_모집_마감_종료_순서다() {
        XCTAssertEqual(DesignRecruitStatus.allCases.map(\.title), ["모집 중", "모집 마감", "종료"])
    }

    func test_모집_중_글자는_accent_highlight다() {
        assertTheme(DesignStatusMenuStyleResolver.text(for: .recruiting), dark: 0xF5FE76FF, light: 0xF29407FF)
    }

    func test_모집_마감_글자는_두_모드_모두_원시_빨강이다() {
        assertTheme(DesignStatusMenuStyleResolver.text(for: .closed), dark: 0xFF5F57FF, light: 0xFF5F57FF)
    }

    func test_종료_글자는_neutral_subtle이다() {
        assertTheme(DesignStatusMenuStyleResolver.text(for: .ended), dark: 0x7A7887FF, light: 0xB0AFB5FF)
    }

    func test_알약_바탕은_overlay_gray_꺾쇠는_subtle이다() {
        assertTheme(DesignStatusMenuStyleResolver.background, dark: 0x706D8266, light: 0xAFAFAF33)
        assertTheme(DesignStatusMenuStyleResolver.chevron, dark: 0x7A7887FF, light: 0xB0AFB5FF)
    }

    func test_알약은_반경_14_여백_6과_11_글자_칸_54_간격_13_꺾쇠_16이다() {
        XCTAssertEqual(DesignStatusMenuMetrics.cornerRadius, 14)
        XCTAssertEqual(DesignStatusMenuMetrics.verticalPadding, 6)
        XCTAssertEqual(DesignStatusMenuMetrics.horizontalPadding, 11)
        XCTAssertEqual(DesignStatusMenuMetrics.labelWidth, 54)
        XCTAssertEqual(DesignStatusMenuMetrics.labelToChevronSpacing, 13)
        XCTAssertEqual(DesignStatusMenuMetrics.chevronSize, 16)
    }

    /// 11 + 54 + 6 + 1 + 6 + 16 + 11 = 105.
    @MainActor
    func test_세_상태_모두_알약_너비가_105다() {
        for status in DesignRecruitStatus.allCases {
            let size = fittingSize(DesignStatusMenu(status: status) { _ in })
            XCTAssertEqual(size.width, 105, accuracy: 0.5, status.title)
        }
    }

    /// 글자 칸은 폭이 고정이라 넘치면 잘린다. 잘리지 않는지 글자만 따로 잰다.
    @MainActor
    func test_세_상태_글자가_글자_칸_54_안에_들어간다() {
        for status in DesignRecruitStatus.allCases {
            let text = DesignText(status.title, style: TextStyle.ds.caption1.semiBold, lineLimit: 1)
            XCTAssertLessThanOrEqual(fittingSize(text).width, DesignStatusMenuMetrics.labelWidth, status.title)
        }
    }

    @MainActor
    private func fittingSize(_ view: some View) -> CGSize {
        let host = UIHostingController(rootView: view.dynamicTypeSize(.large))
        return host.sizeThatFits(in: CGSize(width: 320, height: CGFloat.greatestFiniteMagnitude))
    }
}

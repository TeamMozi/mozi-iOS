@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

@MainActor
final class DesignTopTabBarTests: XCTestCase {
    func test_탭_바는_받은_너비를_가로로_채운다() {
        let bar = DesignTopTabBar(["멤버", "승인 대기", "알림 요청"], selection: "멤버", title: { $0 }, onSelect: { _ in })
        let host = UIHostingController(rootView: bar)
        let size = host.sizeThatFits(in: CGSize(width: 390, height: CGFloat.greatestFiniteMagnitude))
        XCTAssertEqual(size.width, 390, accuracy: 0.5)
    }

    func test_고른_탭과_아닌_탭의_글자색이_다르다() {
        XCTAssertNotEqual(
            DesignTopTabBarStyleResolver.title(isSelected: true),
            DesignTopTabBarStyleResolver.title(isSelected: false)
        )
    }
}

@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

@MainActor
final class DesignAvatarTests: XCTestCase {
    func test_사진이_없어도_받은_지름의_원으로_그린다() {
        for diameter: CGFloat in [24, 40, 56] {
            let host = UIHostingController(rootView: DesignAvatar(nil, diameter: diameter))
            let size = host.sizeThatFits(in: CGSize(width: 320, height: 320))
            XCTAssertEqual(size.width, diameter, accuracy: 0.5)
            XCTAssertEqual(size.height, diameter, accuracy: 0.5)
        }
    }

    func test_사진이_없을_때_바탕은_fill_neutral_subtle이다() {
        XCTAssertEqual(DesignAvatarMetrics.placeholder, SemanticColor.fill.neutral.subtle)
    }

    func test_둥근_사각형도_받은_한_변_길이로_그린다() {
        let avatar = DesignAvatar(nil, diameter: 76, shape: .roundedRectangle(cornerRadius: CGFloat.ds.radius._8))
        let size = UIHostingController(rootView: avatar).sizeThatFits(in: CGSize(width: 320, height: 320))
        XCTAssertEqual(size.width, 76, accuracy: 0.5)
        XCTAssertEqual(size.height, 76, accuracy: 0.5)
    }

    func test_둥근_사각형은_모서리만_깎고_원은_변_가운데만_남긴다() {
        let rect = CGRect(x: 0, y: 0, width: 76, height: 76)
        let rounded = DesignAvatarMetrics.clipShape(for: .roundedRectangle(cornerRadius: 8)).path(in: rect)
        let circle = DesignAvatarMetrics.clipShape(for: .circle).path(in: rect)
        // 윗변 가까이, 모서리 둥근 자리 바로 옆
        XCTAssertTrue(rounded.contains(CGPoint(x: 10, y: 1)))
        XCTAssertFalse(circle.contains(CGPoint(x: 10, y: 1)))
        // 모서리 끝은 둘 다 깎는다
        XCTAssertFalse(rounded.contains(CGPoint(x: 1, y: 1)))
        XCTAssertFalse(circle.contains(CGPoint(x: 1, y: 1)))
    }
}

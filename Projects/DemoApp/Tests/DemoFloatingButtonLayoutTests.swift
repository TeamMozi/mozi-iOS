import CoreGraphics
@testable import MoziDemo
import XCTest

final class DemoFloatingButtonLayoutTests: XCTestCase {
    private let container = CGSize(width: 390, height: 763)

    func test_안쪽으로_옮기면_그대로_둔다() {
        let offset = CGSize(width: -100, height: -200)

        XCTAssertEqual(DemoFloatingButtonLayout.clampedOffset(offset, in: container), offset)
    }

    func test_오른쪽_아래_밖으로_끌면_가장자리에서_멈춘다() {
        let clamped = DemoFloatingButtonLayout.clampedOffset(CGSize(width: 80, height: 300), in: container)

        XCTAssertEqual(clamped, CGSize(width: 0, height: 56))
    }

    func test_왼쪽_위_밖으로_끌면_가장자리에서_멈춘다() {
        let clamped = DemoFloatingButtonLayout.clampedOffset(CGSize(width: -1_000, height: -1_000), in: container)

        XCTAssertEqual(clamped, CGSize(width: -306, height: -623))
    }
}

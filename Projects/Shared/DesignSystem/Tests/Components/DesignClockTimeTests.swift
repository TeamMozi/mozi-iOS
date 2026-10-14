@testable import SharedDesignSystem
import XCTest

final class DesignClockTimeTests: XCTestCase {
    func test_5분_간격_분_칸은_0부터_55까지_12개다() {
        XCTAssertEqual(DesignClockTime.minuteOptions(interval: 5), [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55])
    }

    func test_간격이_0이하면_1분_간격이다() {
        XCTAssertEqual(DesignClockTime.minuteOptions(interval: 0).count, 60)
    }

    func test_시각은_시_분_순으로_비교한다() {
        XCTAssertLessThan(DesignClockTime(hour: 9, minute: 55), DesignClockTime(hour: 10, minute: 0))
        XCTAssertLessThan(DesignClockTime(hour: 20, minute: 0), DesignClockTime(hour: 20, minute: 5))
    }
}

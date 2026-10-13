import Domain
@testable import Feature
import XCTest

final class ClientErrorWrappingTests: XCTestCase {
    func test_모르는_오류는_문구_없는_unknown으로_받는다() {
        struct Other: Error {}
        XCTAssertEqual(MeetingError.wrapping(Other()), .unknown(message: ""))
        XCTAssertEqual(MeetingError.wrapping(MeetingError.network), .network)
        XCTAssertEqual(SnapPointError.wrapping(Other()), .unknown(message: ""))
        XCTAssertEqual(SnapPointError.wrapping(SnapPointError.limitExceeded), .limitExceeded)
    }
}

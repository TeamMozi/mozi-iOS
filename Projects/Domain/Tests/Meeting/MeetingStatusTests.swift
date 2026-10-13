import Domain
import XCTest

final class MeetingStatusTests: XCTestCase {
    func test_종료는_모집_마감에서만_할_수_있다() {
        XCTAssertFalse(MeetingStatus.recruiting.canEnd)
        XCTAssertTrue(MeetingStatus.closed.canEnd)
        XCTAssertFalse(MeetingStatus.ended.canEnd)
    }
}

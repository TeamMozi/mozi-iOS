import SharedUtils
import XCTest

final class SharedUtilsSmokeTests: XCTestCase {
    func test_모듈_임포트() {
        XCTAssertFalse(AppInfo.bundleID.isEmpty)
    }
}

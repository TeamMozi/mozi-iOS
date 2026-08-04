import SharedUtils
import XCTest

final class SharedUtilsSmokeTests: XCTestCase {
    func test_SharedUtils_모듈_임포트_성공() {
        XCTAssertFalse(AppInfo.bundleID.isEmpty)
    }
}

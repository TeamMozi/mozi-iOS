import SharedUtils
import XCTest

final class AppInfoTests: XCTestCase {
    func test_infoPlistKeys() {
        XCTAssertEqual(InfoPlistKey.appVersion.rawValue, "CFBundleShortVersionString")
        XCTAssertEqual(InfoPlistKey.buildNumber.rawValue, "CFBundleVersion")
    }

    func test_versionBuild_format_uses_current_values() {
        let version = AppInfo.version
        let build = AppInfo.buildNumber
        XCTAssertEqual(AppInfo.versionBuild, "\(version) (\(build))")
        XCTAssertFalse(version.isEmpty)
        XCTAssertFalse(build.isEmpty)
    }

    func test_isDebugBuild_is_accessible() {
        _ = AppInfo.isDebugBuild
        XCTAssertTrue(true)
    }
}

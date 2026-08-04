import SharedUtils
import XCTest

final class AppInfoTests: XCTestCase {
    func test_InfoPlist_키_rawValue가_기대값() {
        XCTAssertEqual(InfoPlistKey.appVersion.rawValue, "CFBundleShortVersionString")
        XCTAssertEqual(InfoPlistKey.buildNumber.rawValue, "CFBundleVersion")
    }

    func test_versionBuild_형식이_현재_값_사용() {
        let version = AppInfo.version
        let build = AppInfo.buildNumber
        XCTAssertEqual(AppInfo.versionBuild, "\(version) (\(build))")
        XCTAssertFalse(version.isEmpty)
        XCTAssertFalse(build.isEmpty)
    }

    func test_isDebugBuild가_컴파일_플래그와_일치() {
#if DEBUG
        XCTAssertTrue(AppInfo.isDebugBuild)
#else
        XCTAssertFalse(AppInfo.isDebugBuild)
#endif
    }
}

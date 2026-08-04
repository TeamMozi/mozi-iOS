import XCTest
@testable import SharedDesignSystem

final class FontRegistrationTests: XCTestCase {
    func test_font_resources_exist() {
        let names = [
            "Pretendard-Regular",
            "Pretendard-Medium",
            "Pretendard-SemiBold",
            "Pretendard-Bold",
        ]
        let bundle = SharedDesignSystemResources.bundle

        for name in names {
            XCTAssertNotNil(
                bundle.url(forResource: name, withExtension: "otf")
                    ?? bundle.url(forResource: name, withExtension: "ttf"),
                "Missing font resource: \(name)"
            )
        }
    }

    func test_registerIfNeeded_is_idempotent() {
        let first = DesignSystemFontRegistration.registerIfNeeded()
        let second = DesignSystemFontRegistration.registerIfNeeded()
        XCTAssertTrue(first)
        XCTAssertTrue(second)
    }
}

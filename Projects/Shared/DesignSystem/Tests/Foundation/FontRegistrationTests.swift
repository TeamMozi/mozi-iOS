import XCTest
@testable import SharedDesignSystem

final class FontRegistrationTests: XCTestCase {
    func test_폰트_리소스가_존재() {
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

    func test_registerIfNeeded가_멱등() {
        let first = DesignSystemFontRegistration.registerIfNeeded()
        let second = DesignSystemFontRegistration.registerIfNeeded()
        XCTAssertTrue(first)
        XCTAssertTrue(second)
    }
}

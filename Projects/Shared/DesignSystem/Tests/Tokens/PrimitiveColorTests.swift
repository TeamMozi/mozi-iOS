import XCTest
@testable import SharedDesignSystem

final class PrimitiveColorTests: XCTestCase {
    func test_primary300_hex가_기대값() {
        XCTAssertEqual(PrimitiveColor.Primary._300.hexRGB, 0xE9DE6F)
    }

    func test_neutral1000_hex가_기대값() {
        XCTAssertEqual(PrimitiveColor.Neutral._1000.hexRGB, 0x000000)
    }

    func test_카카오_브랜드_hex가_기대값() {
        XCTAssertEqual(PrimitiveColor.Social.kakaoYellow.hexRGB, 0xFEE500)
    }
}

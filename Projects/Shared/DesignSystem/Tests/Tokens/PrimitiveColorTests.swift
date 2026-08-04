import XCTest
@testable import SharedDesignSystem

final class PrimitiveColorTests: XCTestCase {
    func test_primary300_hex() {
        XCTAssertEqual(PrimitiveColor.Primary._300.hexRGB, 0xE9DE6F)
    }

    func test_neutral1000_hex() {
        XCTAssertEqual(PrimitiveColor.Neutral._1000.hexRGB, 0x000000)
    }

    func test_brand_kakao_hex() {
        XCTAssertEqual(PrimitiveColor.Social.kakaoYellow.hexRGB, 0xFEE500)
    }
}

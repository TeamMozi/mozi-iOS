import XCTest
@testable import SharedDesignSystem

final class SocialLoginProviderTests: XCTestCase {
    func test_카카오_카피와_컬러() {
        XCTAssertEqual(SocialLoginProvider.kakao.title, "카카오로 시작하기")
        XCTAssertEqual(SocialLoginProvider.kakao.background.hexRGB, PrimitiveColor.Social.kakaoYellow.hexRGB)
        XCTAssertEqual(SocialLoginProvider.kakao.content.hexRGB, PrimitiveColor.Neutral._1000.hexRGB)
        XCTAssertNil(SocialLoginProvider.kakao.border)
        XCTAssertEqual(SocialLoginProvider.kakao.contentGap, 12)
    }

    func test_애플_카피와_컬러() {
        XCTAssertEqual(SocialLoginProvider.apple.title, "Apple로 로그인")
        XCTAssertEqual(SocialLoginProvider.apple.background.hexRGB, PrimitiveColor.Neutral._0.hexRGB)
        XCTAssertEqual(SocialLoginProvider.apple.content.hexRGB, PrimitiveColor.Neutral._1000.hexRGB)
        XCTAssertEqual(SocialLoginProvider.apple.border?.hexRGB, PrimitiveColor.Neutral._1000.hexRGB)
        XCTAssertEqual(SocialLoginProvider.apple.contentGap, 9)
    }
}

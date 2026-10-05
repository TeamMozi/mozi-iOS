import CoreGraphics
@testable import SharedDesignSystem
import XCTest

final class SocialLoginProviderTests: XCTestCase {
    func test_카카오는_카카오로_로그인과_노랑_바탕이다() {
        XCTAssertEqual(SocialLoginProvider.kakao.title, "카카오로 로그인")
        XCTAssertEqual(rgba(SocialLoginProvider.kakao.background), 0xFEE500FF)
        XCTAssertEqual(rgba(SocialLoginProvider.kakao.content), 0x0E0E11FF)
        XCTAssertEqual(SocialLoginProvider.kakao.iconSize, CGSize(width: 18, height: 18))
    }

    func test_애플은_애플로_로그인과_흰_바탕이다() {
        XCTAssertEqual(SocialLoginProvider.apple.title, "애플로 로그인")
        XCTAssertEqual(rgba(SocialLoginProvider.apple.background), 0xFFFFFFFF)
        XCTAssertEqual(rgba(SocialLoginProvider.apple.content), 0x0E0E11FF)
        XCTAssertEqual(SocialLoginProvider.apple.iconSize, CGSize(width: 15, height: 18))
    }

    func test_소셜_버튼은_높이_48_반경_8_간격_8이다() {
        XCTAssertEqual(SocialLoginButtonMetrics.height, 48)
        XCTAssertEqual(SocialLoginButtonMetrics.cornerRadius, 8)
        XCTAssertEqual(SocialLoginButtonMetrics.iconSpacing, 8)
    }

    func test_소셜_버튼_글자는_SemiBold_18_줄높이_18_자간_0이다() {
        XCTAssertEqual(
            SocialLoginButtonMetrics.textStyle,
            TextStyle(fontName: "Pretendard-SemiBold", size: 18, lineHeight: 18, letterSpacingEm: 0)
        )
    }
}

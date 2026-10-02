@testable import SharedDesignSystem
import XCTest

final class SocialLoginProviderTests: XCTestCase {
    func test_카카오_카피와_컬러() {
        XCTAssertEqual(SocialLoginProvider.kakao.title, "카카오로 시작하기")
        XCTAssertEqual(rgba(SocialLoginProvider.kakao.background), 0xFEE500FF)
        XCTAssertEqual(rgba(SocialLoginProvider.kakao.content), 0x000000FF)
        XCTAssertNil(SocialLoginProvider.kakao.border)
        XCTAssertEqual(SocialLoginProvider.kakao.contentGap, 12)
    }

    func test_애플_카피와_컬러() {
        XCTAssertEqual(SocialLoginProvider.apple.title, "Apple로 로그인")
        XCTAssertEqual(rgba(SocialLoginProvider.apple.background), 0xFFFFFFFF)
        XCTAssertEqual(rgba(SocialLoginProvider.apple.content), 0x000000FF)
        XCTAssertEqual(SocialLoginProvider.apple.border.map { rgba($0) }, 0x000000FF)
        XCTAssertEqual(SocialLoginProvider.apple.contentGap, 12)
    }
}

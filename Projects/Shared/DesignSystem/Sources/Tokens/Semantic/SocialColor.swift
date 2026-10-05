import Foundation

/// 소셜 로그인 색. 모드와 상관없다.
/// 바탕은 카카오·애플 브랜드 색이고, 글자·아이콘은 Figma login 의 `color/neutral/1200` 이다.
enum SocialColor {
    static let kakao = TokenColor(hexRGB: 0xFEE500)
    static let kakaoContent = PrimitiveColor.neutral._1200
    static let appleBackground = TokenColor(hexRGB: 0xFFFFFF)
    static let appleContent = PrimitiveColor.neutral._1200
}

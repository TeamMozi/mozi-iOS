import CoreGraphics

/// 소셜 로그인 제공자 둘. 문구·로고·색은 Figma login 그대로 고정이다.
public enum SocialLoginProvider: Sendable {
    case kakao
    case apple

    public var title: String {
        switch self {
        case .kakao:
            "카카오로 로그인"
        case .apple:
            "애플로 로그인"
        }
    }

    var background: TokenColor {
        switch self {
        case .kakao:
            SocialColor.kakao
        case .apple:
            SocialColor.appleBackground
        }
    }

    var content: TokenColor {
        switch self {
        case .kakao:
            SocialColor.kakaoContent
        case .apple:
            SocialColor.appleContent
        }
    }

    /// 로고 크기. 카카오 18×18, 애플 15×18.
    var iconSize: CGSize {
        switch self {
        case .kakao:
            CGSize(width: 18, height: 18)
        case .apple:
            CGSize(width: 15, height: 18)
        }
    }
}

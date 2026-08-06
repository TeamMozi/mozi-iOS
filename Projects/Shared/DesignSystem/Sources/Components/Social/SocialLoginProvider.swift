import CoreGraphics

public enum SocialLoginProvider: Sendable {
    case kakao
    case apple

    public var title: String {
        switch self {
        case .kakao:
            "카카오로 시작하기"
        case .apple:
            "Apple로 로그인"
        }
    }

    var background: TokenColor {
        switch self {
        case .kakao:
            SemanticColor.Social.kakao
        case .apple:
            SemanticColor.Social.appleBackground
        }
    }

    var content: TokenColor {
        switch self {
        case .kakao:
            SemanticColor.Social.kakaoContent
        case .apple:
            SemanticColor.Social.appleContent
        }
    }

    var border: TokenColor? {
        switch self {
        case .kakao:
            nil
        case .apple:
            SemanticColor.Social.appleBorder
        }
    }

    var contentGap: CGFloat {
        switch self {
        case .kakao, .apple:
            12
        }
    }

    var iconSize: CGSize {
        switch self {
        case .kakao:
            CGSize(width: 18, height: 18)
        case .apple:
            CGSize(width: 15, height: 18)
        }
    }
}

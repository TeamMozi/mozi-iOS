import SwiftUI

/// 기본 버튼 크기 셋. `.controlSize` 를 Figma Buttons 의 sm·md·lg 로 옮긴다.
enum DesignButtonSize: Equatable, Sendable {
    case sm
    case md
    case lg

    init(_ controlSize: ControlSize) {
        switch controlSize {
        case .mini, .small:
            self = .sm
        case .regular:
            self = .md
        case .large, .extraLarge:
            self = .lg
        @unknown default:
            self = .md
        }
    }

    var height: CGFloat {
        switch self {
        case .sm:
            CGFloat.ds.buttonHeight.controlSm
        case .md:
            CGFloat.ds.buttonHeight.controlMd
        case .lg:
            CGFloat.ds.buttonHeight.controlLg
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .sm:
            CGFloat.ds.spacing.md
        case .md:
            CGFloat.ds.spacing.lg
        case .lg:
            Self.largeHorizontalPadding
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .sm, .md:
            CGFloat.ds.radius._4
        case .lg:
            CGFloat.ds.radius._8
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .sm:
            CGFloat.ds.iconSize._14
        case .md:
            Self.mediumIconSize
        case .lg:
            CGFloat.ds.iconSize._18
        }
    }

    /// 아이콘과 글자 사이. 세 크기가 같다.
    var iconSpacing: CGFloat {
        CGFloat.ds.spacing.sm
    }

    /// 글자는 세 크기 모두 `Headline/SemiBold` 다.
    var textStyle: TextStyle {
        TextStyle.ds.headline.semiBold
    }

    // Figma 에 맞는 변수가 없는 값.
    private static let largeHorizontalPadding: CGFloat = 20
    private static let mediumIconSize: CGFloat = 16
}

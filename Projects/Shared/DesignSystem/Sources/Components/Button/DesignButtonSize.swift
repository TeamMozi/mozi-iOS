import CoreGraphics

public enum DesignButtonSize: Sendable {
    case sm
    case md
    case lg

    public var height: CGFloat {
        switch self {
        case .sm:
            CGFloat.ds.buttonHeight.controlSm
        case .md:
            CGFloat.ds.buttonHeight.controlMd
        case .lg:
            CGFloat.ds.buttonHeight.controlLg
        }
    }

    public var horizontalPadding: CGFloat {
        switch self {
        case .sm:
            12
        case .md:
            16
        case .lg:
            20
        }
    }

    public var cornerRadius: CGFloat {
        switch self {
        case .sm, .md:
            CGFloat.ds.radius._4
        case .lg:
            CGFloat.ds.radius._8
        }
    }

    public var iconSize: CGFloat {
        switch self {
        case .sm:
            14
        case .md:
            16
        case .lg:
            18
        }
    }

    public var textStyle: TextStyle {
        switch self {
        case .sm:
            TextStyle.ds.caption1.semiBold
        case .md:
            TextStyle.ds.headline.semiBold
        case .lg:
            TextStyle.ds.title3.semiBold
        }
    }

    public var contentGap: CGFloat {
        CGFloat.ds.spacing.sm
    }
}

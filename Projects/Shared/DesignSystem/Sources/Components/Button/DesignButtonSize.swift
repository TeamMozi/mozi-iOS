import CoreGraphics

public enum DesignButtonSize: Sendable {
    case sm
    case md
    case lg

    public var height: CGFloat {
        switch self {
        case .sm:
            SemanticNumber.ControlHeight.sm
        case .md:
            SemanticNumber.ControlHeight.md
        case .lg:
            SemanticNumber.ControlHeight.lg
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
            SemanticNumber.Radius.xsm
        case .lg:
            SemanticNumber.Radius.sm
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
            TextStyle.ds.button.sm14Semibold
        case .md:
            TextStyle.ds.button.md16Semibold
        case .lg:
            TextStyle.ds.button.lg18Semibold
        }
    }

    public var contentGap: CGFloat {
        SemanticNumber.Spacing.sm
    }
}

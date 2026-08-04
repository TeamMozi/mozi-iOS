import CoreGraphics

public extension CGFloat {
    static let ds = DesignSystemMetrics()
}

public struct DesignSystemMetrics: Sendable {
    public let radius = RadiusMetrics()
    public let spacing = SpacingMetrics()
    public let border = BorderMetrics()
    public let controlHeight = ControlHeightMetrics()
    public let dim = DimMetrics()

    public init() {}
}

public struct RadiusMetrics: Sendable {
    public let none = SemanticNumber.Radius.none
    public let xsm = SemanticNumber.Radius.xsm
    public let sm = SemanticNumber.Radius.sm
    public let md = SemanticNumber.Radius.md
    public let lg = SemanticNumber.Radius.lg
    public let xxlg = SemanticNumber.Radius.xxlg
    public let full = SemanticNumber.Radius.full

    public init() {}
}

public struct SpacingMetrics: Sendable {
    public let xs = SemanticNumber.Spacing.xs
    public let sm = SemanticNumber.Spacing.sm
    public let md = SemanticNumber.Spacing.md
    public let lg = SemanticNumber.Spacing.lg
    public let xl = SemanticNumber.Spacing.xl
    public let xxl = SemanticNumber.Spacing.xxl

    public init() {}
}

public struct BorderMetrics: Sendable {
    public let thin = SemanticNumber.Border.thin
    public let thick = SemanticNumber.Border.thick

    public init() {}
}

public struct ControlHeightMetrics: Sendable {
    public let sm = SemanticNumber.ControlHeight.sm
    public let md = SemanticNumber.ControlHeight.md
    public let lg = SemanticNumber.ControlHeight.lg

    public init() {}
}

public struct DimMetrics: Sendable {
    public let light = SemanticNumber.Dim.light
    public let `default` = SemanticNumber.Dim.default
    public let heavy = SemanticNumber.Dim.heavy

    public init() {}
}

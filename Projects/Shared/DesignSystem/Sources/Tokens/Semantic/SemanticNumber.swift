import CoreGraphics

enum SemanticNumber {
    enum Radius {
        static let none = PrimitiveNumber.Radius.none
        static let xsm = PrimitiveNumber.Radius.xsm
        static let sm = PrimitiveNumber.Radius.sm
        static let md = PrimitiveNumber.Radius.md
        static let lg = PrimitiveNumber.Radius.lg
        static let xxlg = PrimitiveNumber.Radius.xxlg
        static let full = PrimitiveNumber.Radius.full
    }

    enum Spacing {
        static let xs = PrimitiveNumber.Spacing.xs
        static let sm = PrimitiveNumber.Spacing.sm
        static let md = PrimitiveNumber.Spacing.md
        static let lg = PrimitiveNumber.Spacing.lg
        static let xl = PrimitiveNumber.Spacing.xl
        static let xxl = PrimitiveNumber.Spacing.xxl
    }

    enum Border {
        static let thin = PrimitiveNumber.Border.thin
        static let thick = PrimitiveNumber.Border.thick
    }

    enum ControlHeight {
        static let sm = PrimitiveNumber.ControlHeight.sm
        static let md = PrimitiveNumber.ControlHeight.md
        static let lg = PrimitiveNumber.ControlHeight.lg
    }

    enum Dim {
        static let light = PrimitiveNumber.Dim.light
        static let `default` = PrimitiveNumber.Dim.default
        static let heavy = PrimitiveNumber.Dim.heavy
    }
}

import CoreGraphics

enum PrimitiveNumber {
    enum Radius {
        static let none: CGFloat = 0
        static let xsm: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xxlg: CGFloat = 24
        static let full: CGFloat = 9999
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Border {
        static let thin: CGFloat = 1
        static let thick: CGFloat = 2
    }

    enum ControlHeight {
        static let sm: CGFloat = 32
        static let md: CGFloat = 40
        static let lg: CGFloat = 48
    }

    enum Dim {
        static let light: CGFloat = 0.2
        static let `default`: CGFloat = 0.4
        static let heavy: CGFloat = 0.6
    }
}

import SwiftUI

public extension Font {
    static let ds = DesignSystemFonts()
}

public struct DesignSystemFonts: Sendable {
    public let heading = HeadingFonts()
    public let title = TitleFonts()
    public let body = BodyFonts()
    public let label = LabelFonts()
    public let button = ButtonFonts()

    public init() {}
}

public struct HeadingFonts: Sendable {
    public var large32Bold: Font { TextStyle.ds.heading.large32Bold.font }
    public var large32Semibold: Font { TextStyle.ds.heading.large32Semibold.font }
    public var medium28Bold: Font { TextStyle.ds.heading.medium28Bold.font }
    public var medium28Semibold: Font { TextStyle.ds.heading.medium28Semibold.font }

    public init() {}
}

public struct TitleFonts: Sendable {
    public var large24Bold: Font { TextStyle.ds.title.large24Bold.font }
    public var large24Semibold: Font { TextStyle.ds.title.large24Semibold.font }
    public var medium22Bold: Font { TextStyle.ds.title.medium22Bold.font }
    public var medium22Semibold: Font { TextStyle.ds.title.medium22Semibold.font }
    public var small20Bold: Font { TextStyle.ds.title.small20Bold.font }
    public var small20Semibold: Font { TextStyle.ds.title.small20Semibold.font }
    public var xsmall18Bold: Font { TextStyle.ds.title.xsmall18Bold.font }
    public var xsmall18Semibold: Font { TextStyle.ds.title.xsmall18Semibold.font }

    public init() {}
}

public struct BodyFonts: Sendable {
    public var large18Semibold: Font { TextStyle.ds.body.large18Semibold.font }
    public var large18Regular: Font { TextStyle.ds.body.large18Regular.font }
    public var medium16Semibold: Font { TextStyle.ds.body.medium16Semibold.font }
    public var medium16Regular: Font { TextStyle.ds.body.medium16Regular.font }
    public var small14Semibold: Font { TextStyle.ds.body.small14Semibold.font }
    public var small14Regular: Font { TextStyle.ds.body.small14Regular.font }

    public init() {}
}

public struct LabelFonts: Sendable {
    public var large16Medium: Font { TextStyle.ds.label.large16Medium.font }
    public var medium14Medium: Font { TextStyle.ds.label.medium14Medium.font }
    public var small12Medium: Font { TextStyle.ds.label.small12Medium.font }

    public init() {}
}

public struct ButtonFonts: Sendable {
    public var sm14Semibold: Font { TextStyle.ds.button.sm14Semibold.font }
    public var md16Semibold: Font { TextStyle.ds.button.md16Semibold.font }
    public var lg18Semibold: Font { TextStyle.ds.button.lg18Semibold.font }

    public init() {}
}

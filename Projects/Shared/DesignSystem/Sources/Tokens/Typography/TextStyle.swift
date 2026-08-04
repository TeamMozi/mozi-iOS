import CoreGraphics
import SwiftUI

public struct TextStyle: Sendable, Equatable {
    public let fontName: String
    public let size: CGFloat
    public let lineHeight: CGFloat
    public let letterSpacingEm: CGFloat

    public init(
        fontName: String,
        size: CGFloat,
        lineHeight: CGFloat,
        letterSpacingEm: CGFloat
    ) {
        self.fontName = fontName
        self.size = size
        self.lineHeight = lineHeight
        self.letterSpacingEm = letterSpacingEm
    }

    public var font: Font {
        Font.custom(fontName, size: size)
    }

    public var letterSpacing: CGFloat {
        size * letterSpacingEm
    }

    public var additionalLineSpacing: CGFloat {
        max(0, lineHeight - size)
    }
}

public extension TextStyle {
    static let ds = DesignSystemTextStyles()
}

public struct DesignSystemTextStyles: Sendable {
    public let heading = HeadingTextStyles()
    public let title = TitleTextStyles()
    public let body = BodyTextStyles()
    public let label = LabelTextStyles()
    public let button = ButtonTextStyles()

    public init() {}
}

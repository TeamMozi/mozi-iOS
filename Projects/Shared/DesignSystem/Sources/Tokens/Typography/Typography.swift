import CoreGraphics

enum DesignSystemFontName {
    static let regular = "Pretendard-Regular"
    static let medium = "Pretendard-Medium"
    static let semibold = "Pretendard-SemiBold"
    static let bold = "Pretendard-Bold"
}

public struct HeadingTextStyles: Sendable {
    public let large32Bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 32,
        lineHeight: 40,
        letterSpacingEm: -0.01
    )
    public let large32Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 32,
        lineHeight: 40,
        letterSpacingEm: -0.01
    )
    public let medium28Bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 28,
        lineHeight: 36,
        letterSpacingEm: -0.01
    )
    public let medium28Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 28,
        lineHeight: 36,
        letterSpacingEm: -0.01
    )

    public init() {}
}

public struct TitleTextStyles: Sendable {
    public let large24Bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 24,
        lineHeight: 32,
        letterSpacingEm: -0.01
    )
    public let large24Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 24,
        lineHeight: 32,
        letterSpacingEm: -0.01
    )
    public let medium22Bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 22,
        lineHeight: 30,
        letterSpacingEm: -0.01
    )
    public let medium22Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 22,
        lineHeight: 30,
        letterSpacingEm: -0.01
    )
    public let small20Bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 20,
        lineHeight: 28,
        letterSpacingEm: -0.01
    )
    public let small20Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 20,
        lineHeight: 28,
        letterSpacingEm: -0.01
    )
    public let xsmall18Bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 18,
        lineHeight: 26,
        letterSpacingEm: -0.01
    )
    public let xsmall18Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 18,
        lineHeight: 26,
        letterSpacingEm: -0.01
    )

    public init() {}
}

public struct BodyTextStyles: Sendable {
    public let large18Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 18,
        lineHeight: 30,
        letterSpacingEm: 0
    )
    public let large18Regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 18,
        lineHeight: 30,
        letterSpacingEm: 0
    )
    public let medium16Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 16,
        lineHeight: 28,
        letterSpacingEm: 0
    )
    public let medium16Regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 16,
        lineHeight: 28,
        letterSpacingEm: 0
    )
    public let small14Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 14,
        lineHeight: 24,
        letterSpacingEm: 0
    )
    public let small14Regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 14,
        lineHeight: 24,
        letterSpacingEm: 0
    )

    public init() {}
}

public struct LabelTextStyles: Sendable {
    public let large16Medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 16,
        lineHeight: 20,
        letterSpacingEm: 0.02
    )
    public let medium14Medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 14,
        lineHeight: 20,
        letterSpacingEm: 0.02
    )
    public let small12Medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 12,
        lineHeight: 16,
        letterSpacingEm: 0.02
    )

    public init() {}
}

public struct ButtonTextStyles: Sendable {
    public let sm14Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 14,
        lineHeight: 14,
        letterSpacingEm: 0
    )
    public let md16Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 16,
        lineHeight: 16,
        letterSpacingEm: 0
    )
    public let lg18Semibold = TextStyle(
        fontName: DesignSystemFontName.semibold,
        size: 18,
        lineHeight: 18,
        letterSpacingEm: 0
    )

    public init() {}
}

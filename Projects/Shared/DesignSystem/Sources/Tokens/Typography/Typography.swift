import CoreGraphics

/// Pretendard 네 굵기의 PostScript 이름. `Resources/Fonts/` 의 파일 이름과 같다.
enum DesignSystemFontName {
    static let regular = "Pretendard-Regular"
    static let medium = "Pretendard-Medium"
    static let semiBold = "Pretendard-SemiBold"
    static let bold = "Pretendard-Bold"
}

/// Figma `Title1/*`. 28 / 34, 자간 -2%.
public struct Title1TextStyles: Sendable {
    public let bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 28,
        lineHeight: 34,
        letterSpacingEm: -0.02
    )

    public init() {}
}

/// Figma `Title2/*`. 22 / 28, 자간 -2%.
public struct Title2TextStyles: Sendable {
    public let regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 22,
        lineHeight: 28,
        letterSpacingEm: -0.02
    )
    public let semiBold = TextStyle(
        fontName: DesignSystemFontName.semiBold,
        size: 22,
        lineHeight: 28,
        letterSpacingEm: -0.02
    )
    public let bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 22,
        lineHeight: 28,
        letterSpacingEm: -0.02
    )

    public init() {}
}

/// Figma `Title3/*`. 18 / 24, 자간 -2%.
public struct Title3TextStyles: Sendable {
    public let regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 18,
        lineHeight: 24,
        letterSpacingEm: -0.02
    )
    public let semiBold = TextStyle(
        fontName: DesignSystemFontName.semiBold,
        size: 18,
        lineHeight: 24,
        letterSpacingEm: -0.02
    )

    public init() {}
}

/// Figma `Headline/*`. 16 / 22, 자간 -2%.
public struct HeadlineTextStyles: Sendable {
    public let regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 16,
        lineHeight: 22,
        letterSpacingEm: -0.02
    )
    public let medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 16,
        lineHeight: 22,
        letterSpacingEm: -0.02
    )
    public let semiBold = TextStyle(
        fontName: DesignSystemFontName.semiBold,
        size: 16,
        lineHeight: 22,
        letterSpacingEm: -0.02
    )

    public init() {}
}

/// Figma `Body/*`. 16 / 24, 자간 -1%.
public struct BodyTextStyles: Sendable {
    public let regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 16,
        lineHeight: 24,
        letterSpacingEm: -0.01
    )
    public let medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 16,
        lineHeight: 24,
        letterSpacingEm: -0.01
    )
    public let semiBold = TextStyle(
        fontName: DesignSystemFontName.semiBold,
        size: 16,
        lineHeight: 24,
        letterSpacingEm: -0.01
    )

    public init() {}
}

/// Figma `Subtext/*`. 14 / 20, 자간 -1%.
public struct SubtextTextStyles: Sendable {
    public let regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 14,
        lineHeight: 20,
        letterSpacingEm: -0.01
    )
    public let medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 14,
        lineHeight: 20,
        letterSpacingEm: -0.01
    )

    public init() {}
}

/// Figma `Caption1/*`. 14 / 18, 자간 -1%.
public struct Caption1TextStyles: Sendable {
    public let regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 14,
        lineHeight: 18,
        letterSpacingEm: -0.01
    )
    public let medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 14,
        lineHeight: 18,
        letterSpacingEm: -0.01
    )
    public let semiBold = TextStyle(
        fontName: DesignSystemFontName.semiBold,
        size: 14,
        lineHeight: 18,
        letterSpacingEm: -0.01
    )
    public let bold = TextStyle(
        fontName: DesignSystemFontName.bold,
        size: 14,
        lineHeight: 18,
        letterSpacingEm: -0.01
    )

    public init() {}
}

/// Figma `Caption2/*`. 12 / 14, 자간 -1%.
public struct Caption2TextStyles: Sendable {
    public let regular = TextStyle(
        fontName: DesignSystemFontName.regular,
        size: 12,
        lineHeight: 14,
        letterSpacingEm: -0.01
    )
    public let medium = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 12,
        lineHeight: 14,
        letterSpacingEm: -0.01
    )
    public let semiBold = TextStyle(
        fontName: DesignSystemFontName.semiBold,
        size: 12,
        lineHeight: 14,
        letterSpacingEm: -0.01
    )

    public init() {}
}

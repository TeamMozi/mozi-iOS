import CoreGraphics

public extension CGFloat {
    static let ds = DesignSystemMetrics()
}

/// Figma 숫자 토큰 24개와 그리드 바깥 여백 하나. 이름은 Figma 경로를 낱말 단위로 옮긴다.
public struct DesignSystemMetrics: Sendable {
    public let radius = RadiusMetrics()
    public let spacing = SpacingMetrics()
    public let border = BorderMetrics()
    public let buttonHeight = ButtonHeightMetrics()
    public let iconSize = IconSizeMetrics()
    public let layout = LayoutMetrics()

    public init() {}
}

/// Figma `radius/*`.
public struct RadiusMetrics: Sendable {
    public let none: CGFloat = 0
    public let _4: CGFloat = 4
    public let _6: CGFloat = 6
    public let _8: CGFloat = 8
    public let _10: CGFloat = 10
    public let _12: CGFloat = 12
    public let _16: CGFloat = 16
    public let _24: CGFloat = 24
    public let full: CGFloat = 9999

    public init() {}
}

/// Figma `spacing/*`.
public struct SpacingMetrics: Sendable {
    public let xs: CGFloat = 4
    public let sm: CGFloat = 8
    public let md: CGFloat = 12
    public let lg: CGFloat = 16
    public let xl: CGFloat = 24
    public let xxl: CGFloat = 32

    public init() {}
}

/// Figma `border/*`.
public struct BorderMetrics: Sendable {
    public let thin: CGFloat = 1
    public let thick: CGFloat = 2

    public init() {}
}

/// Figma `Button Height/*`.
public struct ButtonHeightMetrics: Sendable {
    public let controlSm: CGFloat = 36
    public let controlMd: CGFloat = 40
    public let controlLg: CGFloat = 48

    public init() {}
}

/// Figma `icon-size/*`.
public struct IconSizeMetrics: Sendable {
    public let _14: CGFloat = 14
    public let _18: CGFloat = 18
    public let _24: CGFloat = 24
    public let _28: CGFloat = 28

    public init() {}
}

/// Figma 그리드 스타일 `mozi_layout` 의 바깥 여백. 화면 맨 바깥 틀의 좌우 여백에만 쓴다.
public struct LayoutMetrics: Sendable {
    public let margin: CGFloat = 16

    public init() {}
}

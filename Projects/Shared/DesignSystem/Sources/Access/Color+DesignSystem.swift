import SwiftUI

public extension Color {
    static let ds = DesignSystemColors()
}

/// Figma 의미 색 63개와 Figma 밖 소셜 색 다섯. 의미 색은 기기 모드를 따라 바뀐다.
public struct DesignSystemColors: Sendable {
    public let text = TextColors()
    public let fill = FillColors()
    public let border = BorderColors()
    public let button = ButtonColors()
    public let overlay = OverlayColors()
    public let social = SocialColors()

    public init() {}
}

public struct TextColors: Sendable {
    public let neutral = TextNeutralColors()
    public let accent = TextAccentColors()

    public init() {}
}

public struct TextNeutralColors: Sendable {
    public let primary = SemanticColor.text.neutral.primary.color
    public let secondary = SemanticColor.text.neutral.secondary.color
    public let tertiary = SemanticColor.text.neutral.tertiary.color
    public let subtle = SemanticColor.text.neutral.subtle.color
    public let faint = SemanticColor.text.neutral.faint.color
    public let inverse = SemanticColor.text.neutral.inverse.color

    public init() {}
}

public struct TextAccentColors: Sendable {
    public let `default` = SemanticColor.text.accent.default.color
    public let subtle = SemanticColor.text.accent.subtle.color
    public let highlight = SemanticColor.text.accent.highlight.color
    public let strong = SemanticColor.text.accent.strong.color

    public init() {}
}

public struct FillColors: Sendable {
    public let neutral = FillNeutralColors()
    public let accent = FillAccentColors()

    public init() {}
}

public struct FillNeutralColors: Sendable {
    public let `default` = SemanticColor.fill.neutral.default.color
    public let surface = SemanticColor.fill.neutral.surface.color
    public let subtle = SemanticColor.fill.neutral.subtle.color
    public let raised = SemanticColor.fill.neutral.raised.color
    public let strong = SemanticColor.fill.neutral.strong.color
    public let muted = SemanticColor.fill.neutral.muted.color
    public let heavy = SemanticColor.fill.neutral.heavy.color
    public let inverse = SemanticColor.fill.neutral.inverse.color

    public init() {}
}

public struct FillAccentColors: Sendable {
    public let `default` = SemanticColor.fill.accent.default.color
    public let vivid = SemanticColor.fill.accent.vivid.color
    public let muted = SemanticColor.fill.accent.muted.color

    public init() {}
}

public struct BorderColors: Sendable {
    public let neutral = BorderNeutralColors()
    public let accent = BorderAccentColors()

    public init() {}
}

public struct BorderNeutralColors: Sendable {
    public let _0 = SemanticColor.border.neutral._0.color
    public let _10 = SemanticColor.border.neutral._10.color
    public let _20 = SemanticColor.border.neutral._20.color
    public let _30 = SemanticColor.border.neutral._30.color
    public let _40 = SemanticColor.border.neutral._40.color
    public let _50 = SemanticColor.border.neutral._50.color
    public let inverse = SemanticColor.border.neutral.inverse.color

    public init() {}
}

public struct BorderAccentColors: Sendable {
    public let basic = SemanticColor.border.accent.basic.color
    public let dark = SemanticColor.border.accent.dark.color
    public let darker = SemanticColor.border.accent.darker.color

    public init() {}
}

public struct ButtonColors: Sendable {
    public let background = ButtonBackgroundColors()
    public let label = ButtonLabelColors()

    public init() {}
}

public struct ButtonBackgroundColors: Sendable {
    public let main = ButtonBackgroundMainColors()
    public let neutral = ButtonBackgroundNeutralColors()
    public let ghost = ButtonBackgroundGhostColors()
    public let icon = ButtonBackgroundIconColors()

    public init() {}
}

public struct ButtonBackgroundMainColors: Sendable {
    public let `default` = SemanticColor.button.background.main.default.color
    public let pressed = SemanticColor.button.background.main.pressed.color
    public let disabled = SemanticColor.button.background.main.disabled.color

    public init() {}
}

public struct ButtonBackgroundNeutralColors: Sendable {
    public let `default` = SemanticColor.button.background.neutral.default.color
    public let pressed = SemanticColor.button.background.neutral.pressed.color
    public let disabled = SemanticColor.button.background.neutral.disabled.color

    public init() {}
}

public struct ButtonBackgroundGhostColors: Sendable {
    public let `default` = SemanticColor.button.background.ghost.default.color
    public let pressed = SemanticColor.button.background.ghost.pressed.color
    public let disabled = SemanticColor.button.background.ghost.disabled.color

    public init() {}
}

public struct ButtonBackgroundIconColors: Sendable {
    public let `default` = SemanticColor.button.background.icon.default.color

    public init() {}
}

public struct ButtonLabelColors: Sendable {
    public let main = ButtonLabelMainColors()
    public let neutral = ButtonLabelNeutralColors()
    public let ghost = ButtonLabelGhostColors()
    public let text = ButtonLabelTextColors()

    public init() {}
}

public struct ButtonLabelMainColors: Sendable {
    public let `default` = SemanticColor.button.label.main.default.color
    public let pressed = SemanticColor.button.label.main.pressed.color
    public let disabled = SemanticColor.button.label.main.disabled.color

    public init() {}
}

public struct ButtonLabelNeutralColors: Sendable {
    public let `default` = SemanticColor.button.label.neutral.default.color
    public let pressed = SemanticColor.button.label.neutral.pressed.color
    public let disabled = SemanticColor.button.label.neutral.disabled.color

    public init() {}
}

public struct ButtonLabelGhostColors: Sendable {
    public let `default` = SemanticColor.button.label.ghost.default.color
    public let pressed = SemanticColor.button.label.ghost.pressed.color
    public let disabled = SemanticColor.button.label.ghost.disabled.color

    public init() {}
}

public struct ButtonLabelTextColors: Sendable {
    public let accent = SemanticColor.button.label.text.accent.color
    public let neutral = SemanticColor.button.label.text.neutral.color

    public init() {}
}

public struct OverlayColors: Sendable {
    public let dim = OverlayDimColors()
    public let inverse = OverlayInverseColors()
    public let gray = OverlayGrayColors()

    public init() {}
}

public struct OverlayDimColors: Sendable {
    public let _0 = SemanticColor.overlay.dim._0.color
    public let _20 = SemanticColor.overlay.dim._20.color
    public let _40 = SemanticColor.overlay.dim._40.color
    public let _60 = SemanticColor.overlay.dim._60.color
    public let _70 = SemanticColor.overlay.dim._70.color
    public let _90 = SemanticColor.overlay.dim._90.color

    public init() {}
}

public struct OverlayInverseColors: Sendable {
    public let _10 = SemanticColor.overlay.inverse._10.color
    public let _20 = SemanticColor.overlay.inverse._20.color
    public let _40 = SemanticColor.overlay.inverse._40.color

    public init() {}
}

public struct OverlayGrayColors: Sendable {
    public let `default` = SemanticColor.overlay.gray.default.color
    public let plain = SemanticColor.overlay.gray.plain.color

    public init() {}
}

/// 카카오·애플 브랜드 지침 색. Figma 밖이고 모드와 상관없다.
public struct SocialColors: Sendable {
    public let kakao = SocialColor.kakao.color
    public let kakaoContent = SocialColor.kakaoContent.color
    public let appleBackground = SocialColor.appleBackground.color
    public let appleBorder = SocialColor.appleBorder.color
    public let appleContent = SocialColor.appleContent.color

    public init() {}
}

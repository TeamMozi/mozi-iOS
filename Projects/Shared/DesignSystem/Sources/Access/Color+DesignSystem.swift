import SwiftUI

public extension Color {
    static let ds = DesignSystemColors()
}

public struct DesignSystemColors: Sendable {
    public let button = ButtonColors()
    public let text = TextColors()
    public let background = BackgroundColors()
    public let border = BorderColors()
    public let dim = DimColors()
    public let social = SocialColors()

    public init() {}
}

public struct ButtonColors: Sendable {
    public let primary = ButtonPrimaryColors()
    public let secondary = ButtonSecondaryColors()
    public let outlined = ButtonOutlinedColors()
    public let text = ButtonTextColors()

    public init() {}
}

public struct ButtonPrimaryColors: Sendable {
    public let background = ButtonPrimaryBackgroundColors()
    public let content = ButtonPrimaryContentColors()

    public init() {}
}

public struct ButtonPrimaryBackgroundColors: Sendable {
    public let `default` = SemanticColor.Button.Primary.background.default.color
    public let pressed = SemanticColor.Button.Primary.background.pressed.color
    public let disabled = SemanticColor.Button.Primary.background.disabled.color

    public init() {}
}

public struct ButtonPrimaryContentColors: Sendable {
    public let `default` = SemanticColor.Button.Primary.content.default.color
    public let pressed = SemanticColor.Button.Primary.content.pressed.color
    public let disabled = SemanticColor.Button.Primary.content.disabled.color

    public init() {}
}

public struct ButtonSecondaryColors: Sendable {
    public let background = ButtonSecondaryBackgroundColors()
    public let content = ButtonSecondaryContentColors()

    public init() {}
}

public struct ButtonSecondaryBackgroundColors: Sendable {
    public let `default` = SemanticColor.Button.Secondary.background.default.color
    public let pressed = SemanticColor.Button.Secondary.background.pressed.color
    public let disabled = SemanticColor.Button.Secondary.background.disabled.color

    public init() {}
}

public struct ButtonSecondaryContentColors: Sendable {
    public let `default` = SemanticColor.Button.Secondary.content.default.color
    public let pressed = SemanticColor.Button.Secondary.content.pressed.color
    public let disabled = SemanticColor.Button.Secondary.content.disabled.color

    public init() {}
}

public struct ButtonOutlinedColors: Sendable {
    public let background = ButtonOutlinedBackgroundColors()
    public let content = ButtonOutlinedContentColors()
    public let border = ButtonOutlinedBorderColors()

    public init() {}
}

public struct ButtonOutlinedBackgroundColors: Sendable {
    public let `default` = SemanticColor.Button.Outlined.background.default.color
    public let pressed = SemanticColor.Button.Outlined.background.pressed.color
    public let disabled = SemanticColor.Button.Outlined.background.disabled.color

    public init() {}
}

public struct ButtonOutlinedContentColors: Sendable {
    public let `default` = SemanticColor.Button.Outlined.content.default.color
    public let pressed = SemanticColor.Button.Outlined.content.pressed.color
    public let disabled = SemanticColor.Button.Outlined.content.disabled.color

    public init() {}
}

public struct ButtonOutlinedBorderColors: Sendable {
    public let `default` = SemanticColor.Button.Outlined.border.default.color
    public let pressed = SemanticColor.Button.Outlined.border.pressed.color
    public let disabled = SemanticColor.Button.Outlined.border.disabled.color

    public init() {}
}

public struct ButtonTextColors: Sendable {
    public let background = ButtonTextBackgroundColors()
    public let content = ButtonTextContentColors()

    public init() {}
}

public struct ButtonTextBackgroundColors: Sendable {
    public let `default` = SemanticColor.Button.Text.background.default.color
    public let pressed = SemanticColor.Button.Text.background.pressed.color
    public let disabled = SemanticColor.Button.Text.background.disabled.color

    public init() {}
}

public struct ButtonTextContentColors: Sendable {
    public let `default` = SemanticColor.Button.Text.content.default.color
    public let pressed = SemanticColor.Button.Text.content.pressed.color
    public let disabled = SemanticColor.Button.Text.content.disabled.color

    public init() {}
}

public struct TextColors: Sendable {
    public let neutral = TextNeutralColors()
    public let primary = TextPrimaryColors()
    public let secondary = TextSecondaryColors()

    public init() {}
}

public struct TextNeutralColors: Sendable {
    public let black = SemanticColor.Text.Neutral.black.color
    public let darker = SemanticColor.Text.Neutral.darker.color
    public let dark = SemanticColor.Text.Neutral.dark.color
    public let basic = SemanticColor.Text.Neutral.basic.color
    public let light = SemanticColor.Text.Neutral.light.color
    public let lighter = SemanticColor.Text.Neutral.lighter.color
    public let white = SemanticColor.Text.Neutral.white.color

    public init() {}
}

public struct TextPrimaryColors: Sendable {
    public let basic = SemanticColor.Text.Primary.basic.color
    public let dark = SemanticColor.Text.Primary.dark.color
    public let darker = SemanticColor.Text.Primary.darker.color

    public init() {}
}

public struct TextSecondaryColors: Sendable {
    public let basic = SemanticColor.Text.Secondary.basic.color
    public let darker = SemanticColor.Text.Secondary.darker.color

    public init() {}
}

public struct BackgroundColors: Sendable {
    public let black = SemanticColor.Background.black.color
    public let grayDarker = SemanticColor.Background.grayDarker.color
    public let grayDark = SemanticColor.Background.grayDark.color

    public init() {}
}

public struct BorderColors: Sendable {
    public let primary = BorderPrimaryColors()
    public let neutral = BorderNeutralColors()

    public init() {}
}

public struct BorderPrimaryColors: Sendable {
    public let basic = SemanticColor.Border.Primary.basic.color
    public let dark = SemanticColor.Border.Primary.dark.color
    public let darker = SemanticColor.Border.Primary.darker.color

    public init() {}
}

public struct BorderNeutralColors: Sendable {
    public let lighter = SemanticColor.Border.Neutral.lighter.color
    public let light = SemanticColor.Border.Neutral.light.color
    public let basic = SemanticColor.Border.Neutral.basic.color
    public let dark = SemanticColor.Border.Neutral.dark.color
    public let darker = SemanticColor.Border.Neutral.darker.color

    public init() {}
}

public struct DimColors: Sendable {
    public let light = SemanticColor.Dim.light.color
    public let `default` = SemanticColor.Dim.default.color
    public let heavy = SemanticColor.Dim.heavy.color

    public init() {}
}

public struct SocialColors: Sendable {
    public let kakao = SemanticColor.Social.kakao.color
    public let kakaoContent = SemanticColor.Social.kakaoContent.color
    public let appleBackground = SemanticColor.Social.appleBackground.color
    public let appleBorder = SemanticColor.Social.appleBorder.color
    public let appleContent = SemanticColor.Social.appleContent.color

    public init() {}
}

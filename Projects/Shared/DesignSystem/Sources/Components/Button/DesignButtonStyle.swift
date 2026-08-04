import CoreGraphics
import SwiftUI

enum DesignButtonInteractionState: Sendable {
    case `default`
    case pressed
    case disabled
}

struct DesignButtonResolvedStyle: Equatable, Sendable {
    let background: TokenColor
    let content: TokenColor
    let border: TokenColor?
    let borderWidth: CGFloat
}

enum DesignButtonStyleResolver {
    static func resolve(
        variant: DesignButtonVariant,
        state: DesignButtonInteractionState
    ) -> DesignButtonResolvedStyle {
        switch variant {
        case .primary:
            resolvePrimary(state: state)
        case .secondary:
            resolveSecondary(state: state)
        case .outlined:
            resolveOutlined(state: state)
        case .text:
            resolveText(state: state)
        }
    }

    private static func resolvePrimary(
        state: DesignButtonInteractionState
    ) -> DesignButtonResolvedStyle {
        switch state {
        case .default:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Primary.background.default,
                content: SemanticColor.Button.Primary.content.default,
                border: nil,
                borderWidth: 0
            )
        case .pressed:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Primary.background.pressed,
                content: SemanticColor.Button.Primary.content.pressed,
                border: nil,
                borderWidth: 0
            )
        case .disabled:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Primary.background.disabled,
                content: SemanticColor.Button.Primary.content.disabled,
                border: nil,
                borderWidth: 0
            )
        }
    }

    private static func resolveSecondary(
        state: DesignButtonInteractionState
    ) -> DesignButtonResolvedStyle {
        switch state {
        case .default:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Secondary.background.default,
                content: SemanticColor.Button.Secondary.content.default,
                border: nil,
                borderWidth: 0
            )
        case .pressed:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Secondary.background.pressed,
                content: SemanticColor.Button.Secondary.content.pressed,
                border: nil,
                borderWidth: 0
            )
        case .disabled:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Secondary.background.disabled,
                content: SemanticColor.Button.Secondary.content.disabled,
                border: nil,
                borderWidth: 0
            )
        }
    }

    private static func resolveOutlined(
        state: DesignButtonInteractionState
    ) -> DesignButtonResolvedStyle {
        switch state {
        case .default:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Outlined.background.default,
                content: SemanticColor.Button.Outlined.content.default,
                border: SemanticColor.Button.Outlined.border.default,
                borderWidth: SemanticNumber.Border.thin
            )
        case .pressed:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Outlined.background.pressed,
                content: SemanticColor.Button.Outlined.content.pressed,
                border: SemanticColor.Button.Outlined.border.pressed,
                borderWidth: SemanticNumber.Border.thin
            )
        case .disabled:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Outlined.background.disabled,
                content: SemanticColor.Button.Outlined.content.disabled,
                border: SemanticColor.Button.Outlined.border.disabled,
                borderWidth: SemanticNumber.Border.thin
            )
        }
    }

    private static func resolveText(
        state: DesignButtonInteractionState
    ) -> DesignButtonResolvedStyle {
        switch state {
        case .default:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Text.background.default,
                content: SemanticColor.Button.Text.content.default,
                border: nil,
                borderWidth: 0
            )
        case .pressed:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Text.background.pressed,
                content: SemanticColor.Button.Text.content.pressed,
                border: nil,
                borderWidth: 0
            )
        case .disabled:
            DesignButtonResolvedStyle(
                background: SemanticColor.Button.Text.background.disabled,
                content: SemanticColor.Button.Text.content.disabled,
                border: nil,
                borderWidth: 0
            )
        }
    }
}

enum DesignButtonInteractionStateResolver {
    static func resolve(isEnabled: Bool, isPressed: Bool) -> DesignButtonInteractionState {
        if !isEnabled {
            return .disabled
        }
        return isPressed ? .pressed : .default
    }
}

struct DesignButtonChromeStyle: ButtonStyle {
    let variant: DesignButtonVariant
    let size: DesignButtonSize
    let isFullWidth: Bool

    func makeBody(configuration: Configuration) -> some View {
        // 중첩 content 가 `@Environment(\.isEnabled)` 를 읽어
        // 부모 `.disabled` 와 `DesignButton(isEnabled:)` 모두 disabled 토큰을 선택한다.
        ChromeContent(
            configuration: configuration,
            variant: variant,
            size: size,
            isFullWidth: isFullWidth
        )
    }
}

private struct ChromeContent: View {
    let configuration: ButtonStyle.Configuration
    let variant: DesignButtonVariant
    let size: DesignButtonSize
    let isFullWidth: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let style = DesignButtonStyleResolver.resolve(
            variant: variant,
            state: DesignButtonInteractionStateResolver.resolve(
                isEnabled: isEnabled,
                isPressed: configuration.isPressed
            )
        )

        // 레이아웃 ownership:
        // label → horizontal padding → expand/height → chrome.
        // padding 이 maxWidth 확장보다 앞서야 full-width 버튼이 parent-width + padding 을 요청하지 않는다.
        configuration.label
            .foregroundStyle(style.content.color)
            .padding(.horizontal, size.horizontalPadding)
            .frame(
                maxWidth: isFullWidth ? .infinity : nil,
                minHeight: size.height,
                maxHeight: size.height
            )
            .background(style.background.color)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
            .overlay {
                if let border = style.border {
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .strokeBorder(border.color, lineWidth: style.borderWidth)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
    }
}

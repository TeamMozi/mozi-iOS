import CoreGraphics
import SwiftUI

enum DesignButtonInteractionState: Sendable {
    case `default`
    case pressed
    case disabled
}

/// 버튼 한 상태의 색과 테두리. 색은 다크·라이트 쌍이다.
struct DesignButtonResolvedStyle: Equatable, Sendable {
    let background: ThemedColor
    let content: ThemedColor
    let border: ThemedColor?
    let borderWidth: CGFloat
}

/// 버튼 모양 넷을 Figma 버튼 묶음 색으로 옮긴다.
/// primary → main, secondary → neutral, outlined → ghost, text → text.
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

    private static func resolvePrimary(state: DesignButtonInteractionState) -> DesignButtonResolvedStyle {
        let background = SemanticColor.button.background.main
        let label = SemanticColor.button.label.main
        switch state {
        case .default:
            return filled(background: background.default, content: label.default)
        case .pressed:
            return filled(background: background.pressed, content: label.pressed)
        case .disabled:
            return filled(background: background.disabled, content: label.disabled)
        }
    }

    private static func resolveSecondary(state: DesignButtonInteractionState) -> DesignButtonResolvedStyle {
        let background = SemanticColor.button.background.neutral
        let label = SemanticColor.button.label.neutral
        switch state {
        case .default:
            return filled(background: background.default, content: label.default)
        case .pressed:
            return filled(background: background.pressed, content: label.pressed)
        case .disabled:
            return filled(background: background.disabled, content: label.disabled)
        }
    }

    // ghost 묶음에는 테두리 색이 없다. 전과 같은 모양을 지키려고 테두리는 글자 색을 따른다.
    private static func resolveOutlined(state: DesignButtonInteractionState) -> DesignButtonResolvedStyle {
        let background = SemanticColor.button.background.ghost
        let label = SemanticColor.button.label.ghost
        switch state {
        case .default:
            return outlined(background: background.default, content: label.default)
        case .pressed:
            return outlined(background: background.pressed, content: label.pressed)
        case .disabled:
            return outlined(background: background.disabled, content: label.disabled)
        }
    }

    // text 묶음에는 글자 색만 있다. 바탕은 투명한 `overlay.dim._0` 이다.
    private static func resolveText(state: DesignButtonInteractionState) -> DesignButtonResolvedStyle {
        let clear = SemanticColor.overlay.dim._0
        let label = SemanticColor.button.label.text
        switch state {
        case .default, .pressed:
            return filled(background: clear, content: label.accent)
        case .disabled:
            return filled(background: clear, content: label.neutral)
        }
    }

    private static func filled(background: ThemedColor, content: ThemedColor) -> DesignButtonResolvedStyle {
        DesignButtonResolvedStyle(background: background, content: content, border: nil, borderWidth: 0)
    }

    private static func outlined(background: ThemedColor, content: ThemedColor) -> DesignButtonResolvedStyle {
        DesignButtonResolvedStyle(
            background: background,
            content: content,
            border: content,
            borderWidth: CGFloat.ds.border.thin
        )
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

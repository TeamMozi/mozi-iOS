import SwiftUI

/// 글자 버튼 종류. Figma Text Btn 의 Gray(`neutral`)와 Color(`accent`).
public enum DesignTextButtonKind: Equatable, Sendable {
    case neutral
    case accent
}

/// 글자 버튼 겉모양. 바탕·여백 없이 글자와 오른쪽 아이콘만 그린다. 크기는 하나다.
/// 눌리면 불투명도 0.88 이고, 비활성이어도 모양은 그대로다.
public struct DesignTextButtonStyle: ButtonStyle {
    let kind: DesignTextButtonKind

    public func makeBody(configuration: Configuration) -> some View {
        DesignTextButtonBody(configuration: configuration, kind: kind)
    }
}

public extension ButtonStyle where Self == DesignTextButtonStyle {
    /// 글자 버튼. 아이콘은 `Button(_:icon:)` 로 넘기면 글자 오른쪽에 놓인다.
    static func textButton(_ kind: DesignTextButtonKind) -> Self {
        DesignTextButtonStyle(kind: kind)
    }
}

/// 글자 버튼의 색과 치수. Figma `button/label/text/*`.
enum DesignTextButtonResolver {
    static let height: CGFloat = 18
    static let textStyle = TextStyle.ds.caption1.medium

    static func iconSize(kind: DesignTextButtonKind) -> CGFloat {
        switch kind {
        case .neutral:
            CGFloat.ds.iconSize._14
        case .accent:
            CGFloat.ds.iconSize._18
        }
    }

    static func palette(kind: DesignTextButtonKind, state: DesignButtonState) -> DesignButtonPalette {
        let content = switch kind {
        case .neutral:
            SemanticColor.button.label.text.neutral
        case .accent:
            SemanticColor.button.label.text.accent
        }
        return DesignButtonPalette(
            background: nil,
            content: content,
            opacity: DesignButtonPressedOpacity.value(isPressed: state == .pressed)
        )
    }
}

private struct DesignTextButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: DesignTextButtonKind

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let palette = DesignTextButtonResolver.palette(
            kind: kind,
            state: DesignButtonState(isEnabled: isEnabled, isPressed: configuration.isPressed)
        )

        configuration.label
            .labelStyle(
                DesignButtonLabelStyle(
                    iconSize: DesignTextButtonResolver.iconSize(kind: kind),
                    spacing: 0,
                    placement: .trailing
                )
            )
            .designButtonText(DesignTextButtonResolver.textStyle)
            .foregroundStyle(palette.content.color)
            .frame(height: DesignTextButtonResolver.height)
            .contentShape(Rectangle())
            .opacity(palette.opacity)
    }
}

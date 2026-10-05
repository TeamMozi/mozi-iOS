import SwiftUI

/// 알약 글자 버튼 겉모양. Figma btn_text.
/// 활성은 iOS 26 시스템 유리 효과 위 글자이고, 눌림은 유리의 시스템 반응만 쓴다.
/// 비활성은 유리 효과와 바탕 없이 옅은 글자만 그린다. 크기는 하나다.
public struct DesignPillButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        DesignPillButtonBody(configuration: configuration)
    }
}

public extension ButtonStyle where Self == DesignPillButtonStyle {
    /// 유리 효과 알약 글자 버튼.
    static var pill: Self {
        DesignPillButtonStyle()
    }
}

/// 알약 글자 버튼의 치수·글자 색·유리 효과 여부.
enum DesignPillButtonResolver {
    static let height: CGFloat = 32
    static let horizontalPadding = CGFloat.ds.spacing.md
    static let textStyle = TextStyle.ds.subtext.medium

    static func palette(state: DesignButtonState) -> DesignButtonPalette {
        let content = switch state {
        case .default, .pressed:
            SemanticColor.text.neutral.primary
        case .disabled:
            SemanticColor.text.neutral.subtle
        }
        return DesignButtonPalette(background: nil, content: content, opacity: 1)
    }

    static func usesGlass(state: DesignButtonState) -> Bool {
        state != .disabled
    }
}

private struct DesignPillButtonBody: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let state = DesignButtonState(isEnabled: isEnabled, isPressed: configuration.isPressed)
        let palette = DesignPillButtonResolver.palette(state: state)
        let label = configuration.label
            .designButtonText(DesignPillButtonResolver.textStyle)
            .foregroundStyle(palette.content.color)
            .padding(.horizontal, DesignPillButtonResolver.horizontalPadding)
            .frame(height: DesignPillButtonResolver.height)
            .contentShape(Capsule())

        if DesignPillButtonResolver.usesGlass(state: state) {
            label.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            label
        }
    }
}

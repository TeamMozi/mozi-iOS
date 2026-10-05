import SwiftUI

/// Shortcut 모양. Figma Shortcut / Circle 과 Shortcut / Tile.
public enum DesignShortcutButtonKind: Equatable, Sendable {
    case circle
    case tile
}

/// Shortcut 버튼 겉모양. 아이콘만 그린다(제목은 VoiceOver 가 읽는다). 아이콘은 `Button(_:icon:)` 로 넘긴다.
/// 크기는 하나다. 눌리면 불투명도 0.88, 비활성은 Figma Disabled 색이다.
public struct DesignShortcutButtonStyle: ButtonStyle {
    let kind: DesignShortcutButtonKind

    public func makeBody(configuration: Configuration) -> some View {
        DesignShortcutButtonBody(configuration: configuration, kind: kind)
    }
}

public extension ButtonStyle where Self == DesignShortcutButtonStyle {
    /// 아이콘 하나를 둥근 바탕에 올린 Shortcut 버튼.
    static func shortcut(_ kind: DesignShortcutButtonKind) -> Self {
        DesignShortcutButtonStyle(kind: kind)
    }
}

/// Shortcut 의 치수와 색.
enum DesignShortcutButtonResolver {
    static let iconSize = CGFloat.ds.iconSize._24

    static func side(kind: DesignShortcutButtonKind) -> CGFloat {
        switch kind {
        case .circle:
            circleSide
        case .tile:
            tileSide
        }
    }

    static let tileCornerRadius = CGFloat.ds.radius._12

    static func palette(kind: DesignShortcutButtonKind, state: DesignButtonState) -> DesignButtonPalette {
        switch state {
        case .disabled:
            return DesignButtonPalette(
                background: SemanticColor.fill.neutral.subtle,
                content: SemanticColor.text.neutral.faint,
                opacity: 1
            )
        case .default, .pressed:
            let background = switch kind {
            case .circle:
                SemanticColor.fill.neutral.muted
            case .tile:
                SemanticColor.fill.neutral.raised
            }
            return DesignButtonPalette(
                background: background,
                content: SemanticColor.text.neutral.primary,
                opacity: DesignButtonPressedOpacity.value(isPressed: state == .pressed)
            )
        }
    }

    // Figma 에 맞는 변수가 없는 값.
    private static let circleSide: CGFloat = 48
    private static let tileSide: CGFloat = 44
}

private struct DesignShortcutButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: DesignShortcutButtonKind

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let palette = DesignShortcutButtonResolver.palette(
            kind: kind,
            state: DesignButtonState(isEnabled: isEnabled, isPressed: configuration.isPressed)
        )
        let side = DesignShortcutButtonResolver.side(kind: kind)
        let shape = DesignShortcutShape(kind: kind)

        configuration.label
            .labelStyle(DesignShortcutLabelStyle())
            .scaledToFit()
            .frame(width: DesignShortcutButtonResolver.iconSize, height: DesignShortcutButtonResolver.iconSize)
            .foregroundStyle(palette.content.color)
            .frame(width: side, height: side)
            .designButtonBackground(palette.background, in: shape)
            .contentShape(shape)
            .opacity(palette.opacity)
    }
}

/// 아이콘만 그리고 제목은 VoiceOver 이름으로 남긴다.
/// 디자인 시스템 아이콘은 장식용(`Image(decorative:)`)이라 시스템 `.iconOnly` 로는 이름이 사라진다.
private struct DesignShortcutLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .accessibilityRepresentation { configuration.title }
    }
}

/// circle 은 완전한 원이다. 반경이 큰 `.continuous` 사각형은 원보다 살짝 각진다.
private struct DesignShortcutShape: Shape {
    let kind: DesignShortcutButtonKind

    func path(in rect: CGRect) -> Path {
        switch kind {
        case .circle:
            Circle().path(in: rect)
        case .tile:
            RoundedRectangle(cornerRadius: DesignShortcutButtonResolver.tileCornerRadius, style: .continuous)
                .path(in: rect)
        }
    }
}

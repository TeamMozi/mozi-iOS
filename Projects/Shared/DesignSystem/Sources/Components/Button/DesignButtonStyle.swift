import SwiftUI

/// 기본 버튼 계열 셋. Figma Buttons 의 `Style=main·neutral·ghost`.
enum DesignButtonKind: Equatable, Sendable {
    case main
    case neutral
    case ghost
}

/// 기본 버튼 겉모양. Figma `button/background/*`·`button/label/*` 색을 쓴다.
/// 크기는 `.controlSize`, 비활성은 `.disabled()`, 너비 채우기는 내용에 `.frame(maxWidth: .infinity)` 로 정한다.
/// 아이콘은 `Button(_:icon:)` 로 넘기면 글자 왼쪽에 놓인다.
public struct DesignButtonStyle: ButtonStyle {
    let kind: DesignButtonKind

    public func makeBody(configuration: Configuration) -> some View {
        DesignButtonBody(configuration: configuration, kind: kind)
    }
}

public extension ButtonStyle where Self == DesignButtonStyle {
    /// 노랑 바탕 버튼. Figma `Style=main`.
    static var main: Self {
        DesignButtonStyle(kind: .main)
    }

    /// 회색 바탕 버튼. Figma `Style=neutral`.
    static var neutral: Self {
        DesignButtonStyle(kind: .neutral)
    }

    /// 화면 바탕과 같은 색 위 노랑 글자 버튼. 테두리가 없다. Figma `Style=ghost`.
    static var ghost: Self {
        DesignButtonStyle(kind: .ghost)
    }
}

/// 기본 버튼 한 계열·한 상태의 색. 눌림을 색으로 보이므로 불투명도는 늘 1 이다.
enum DesignButtonStyleResolver {
    static func palette(kind: DesignButtonKind, state: DesignButtonState) -> DesignButtonPalette {
        switch kind {
        case .main:
            mainPalette(state: state)
        case .neutral:
            neutralPalette(state: state)
        case .ghost:
            ghostPalette(state: state)
        }
    }

    private static func mainPalette(state: DesignButtonState) -> DesignButtonPalette {
        let background = SemanticColor.button.background.main
        let label = SemanticColor.button.label.main
        switch state {
        case .default:
            return DesignButtonPalette(background: background.default, content: label.default, opacity: 1)
        case .pressed:
            return DesignButtonPalette(background: background.pressed, content: label.pressed, opacity: 1)
        case .disabled:
            return DesignButtonPalette(background: background.disabled, content: label.disabled, opacity: 1)
        }
    }

    private static func neutralPalette(state: DesignButtonState) -> DesignButtonPalette {
        let background = SemanticColor.button.background.neutral
        let label = SemanticColor.button.label.neutral
        switch state {
        case .default:
            return DesignButtonPalette(background: background.default, content: label.default, opacity: 1)
        case .pressed:
            return DesignButtonPalette(background: background.pressed, content: label.pressed, opacity: 1)
        case .disabled:
            return DesignButtonPalette(background: background.disabled, content: label.disabled, opacity: 1)
        }
    }

    private static func ghostPalette(state: DesignButtonState) -> DesignButtonPalette {
        let background = SemanticColor.button.background.ghost
        let label = SemanticColor.button.label.ghost
        switch state {
        case .default:
            return DesignButtonPalette(background: background.default, content: label.default, opacity: 1)
        case .pressed:
            return DesignButtonPalette(background: background.pressed, content: label.pressed, opacity: 1)
        case .disabled:
            return DesignButtonPalette(background: background.disabled, content: label.disabled, opacity: 1)
        }
    }
}

/// 환경 값(비활성·크기)은 스타일 구조체가 아니라 이 View 에서 읽어야 부모에 건 수식어를 따른다.
private struct DesignButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: DesignButtonKind

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize

    var body: some View {
        let size = DesignButtonSize(controlSize)
        let palette = DesignButtonStyleResolver.palette(
            kind: kind,
            state: DesignButtonState(isEnabled: isEnabled, isPressed: configuration.isPressed)
        )
        let shape = RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)

        // 순서: 글자 → 좌우 여백 → 높이 → 바탕. 너비 채우기는 내용의 maxWidth 가 여백 안에서 늘어난다.
        configuration.label
            .labelStyle(
                DesignButtonLabelStyle(
                    iconSize: size.iconSize,
                    spacing: size.iconSpacing,
                    placement: .leading
                )
            )
            .designButtonText(size.textStyle)
            .foregroundStyle(palette.content.color)
            .padding(.horizontal, size.horizontalPadding)
            .frame(height: size.height)
            .designButtonBackground(palette.background, in: shape)
            .contentShape(shape)
            .opacity(palette.opacity)
    }
}

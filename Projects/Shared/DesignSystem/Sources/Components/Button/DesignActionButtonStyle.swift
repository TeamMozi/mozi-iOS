import SwiftUI

/// 액션 버튼 종류. `accent` 는 노랑 원, `neutral` 은 회색 원이다.
public enum DesignActionButtonKind: Equatable, Sendable {
    case accent
    case neutral
}

/// 액션 버튼 겉모양. 원 안에 아이콘, 그 아래에 글자를 둔다. 아이콘은 `Button(_:icon:)` 로 넘긴다.
/// 크기는 `.controlSize` 가 `.small` 이하면 s, 그 밖은 m 이다.
/// 눌리면 불투명도 0.88 이고, 비활성이어도 모양은 그대로다.
public struct DesignActionButtonStyle: ButtonStyle {
    let kind: DesignActionButtonKind

    public func makeBody(configuration: Configuration) -> some View {
        DesignActionButtonBody(configuration: configuration, kind: kind)
    }
}

public extension ButtonStyle where Self == DesignActionButtonStyle {
    /// 원 안 아이콘과 아래 글자로 된 액션 버튼.
    static func action(_ kind: DesignActionButtonKind) -> Self {
        DesignActionButtonStyle(kind: kind)
    }
}

/// 액션 버튼 크기 둘. `.controlSize` 를 Figma action button 의 s·m 으로 옮긴다.
enum DesignActionButtonSize: Equatable, Sendable {
    case s
    case m

    init(_ controlSize: ControlSize) {
        switch controlSize {
        case .mini, .small:
            self = .s
        case .regular, .large, .extraLarge:
            self = .m
        @unknown default:
            self = .m
        }
    }

    var circleDiameter: CGFloat {
        switch self {
        case .s:
            Self.smallCircleDiameter
        case .m:
            Self.mediumCircleDiameter
        }
    }

    var iconSize: CGFloat {
        CGFloat.ds.iconSize._24
    }

    /// 원과 글자 사이.
    var spacing: CGFloat {
        CGFloat.ds.spacing.sm
    }

    var textStyle: TextStyle {
        switch self {
        case .s:
            TextStyle.ds.caption1.medium
        case .m:
            TextStyle.ds.headline.medium
        }
    }

    var titleColor: ThemedColor {
        switch self {
        case .s:
            SemanticColor.text.neutral.tertiary
        case .m:
            SemanticColor.text.neutral.primary
        }
    }

    // Figma 에 맞는 변수가 없는 값.
    private static let smallCircleDiameter: CGFloat = 36
    private static let mediumCircleDiameter: CGFloat = 52
}

/// 액션 버튼 원의 색과 아이콘 색.
enum DesignActionButtonResolver {
    static func palette(kind: DesignActionButtonKind, state: DesignButtonState) -> DesignButtonPalette {
        let opacity = DesignButtonPressedOpacity.value(isPressed: state == .pressed)
        switch kind {
        case .accent:
            return DesignButtonPalette(background: accentCircle, content: accentIcon, opacity: opacity)
        case .neutral:
            return DesignButtonPalette(
                background: SemanticColor.fill.neutral.subtle,
                content: SemanticColor.text.neutral.primary,
                opacity: opacity
            )
        }
    }

    // Figma 가 의미 색 없이 원시 색 `color/primary/50`·`color/neutral/1300` 을 쓴다. 두 모드가 같다.
    private static let accentCircle = ThemedColor(
        dark: PrimitiveColor.primary._50,
        light: PrimitiveColor.primary._50
    )
    private static let accentIcon = ThemedColor(
        dark: PrimitiveColor.neutral._1300,
        light: PrimitiveColor.neutral._1300
    )
}

private struct DesignActionButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: DesignActionButtonKind

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize

    var body: some View {
        let palette = DesignActionButtonResolver.palette(
            kind: kind,
            state: DesignButtonState(isEnabled: isEnabled, isPressed: configuration.isPressed)
        )

        configuration.label
            .labelStyle(DesignActionButtonLabelStyle(size: DesignActionButtonSize(controlSize), palette: palette))
            .contentShape(Rectangle())
            .opacity(palette.opacity)
    }
}

/// 액션 버튼 내용. 원 안에 아이콘을, 그 아래에 글자를 둔다.
private struct DesignActionButtonLabelStyle: LabelStyle {
    let size: DesignActionButtonSize
    let palette: DesignButtonPalette

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: size.spacing) {
            configuration.icon
                .scaledToFit()
                .frame(width: size.iconSize, height: size.iconSize)
                .foregroundStyle(palette.content.color)
                .frame(width: size.circleDiameter, height: size.circleDiameter)
                .designButtonBackground(palette.background, in: Circle())

            configuration.title
                .designButtonLineBoxText(size.textStyle)
                .foregroundStyle(size.titleColor.color)
        }
    }
}

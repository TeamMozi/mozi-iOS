import CoreGraphics

/// 칩 꼴.
public enum DesignChipStyle: Equatable, Sendable {
    /// 테두리형. 닫기 아이콘을 켜고 끈다.
    case outlined
    /// 채움형. 닫기 아이콘을 켜고 끈다.
    case filled
    /// 알약형. 「편집 중」에 따라 글자색이 바뀐다(시안 active · disabled). 닫기 아이콘이 없다.
    case pill
}

/// 칩의 색. 없는 칠은 nil 이다. `icon` 은 닫기 아이콘 색이다.
struct DesignChipPalette: Equatable, Sendable {
    let background: ThemedColor?
    let border: ThemedColor?
    let content: ThemedColor
    let icon: ThemedColor
}

/// 칩의 글자·여백. 꼴에 상관없는 치수는 static 이다. 모양은 꼴에 상관없이 알약이다.
struct DesignChipMetrics: Equatable, Sendable {
    let textStyle: TextStyle
    let horizontalPadding: CGFloat

    static let height: CGFloat = 32
    static let verticalPadding: CGFloat = CGFloat.ds.spacing.xs
    static let spacing: CGFloat = CGFloat.ds.spacing.xs
    static let closeIconSize: CGFloat = CGFloat.ds.iconSize._14
}

/// Figma Chip 의 꼴별 색과 치수. 채움형 글자·닫기는 시안이 원시 색을 바로 쓴다.
enum DesignChipStyleResolver {
    static func palette(style: DesignChipStyle, isEditing: Bool) -> DesignChipPalette {
        switch style {
        case .outlined:
            DesignChipPalette(
                background: nil,
                border: SemanticColor.border.neutral._40,
                content: SemanticColor.text.neutral.secondary,
                icon: SemanticColor.text.neutral.secondary
            )
        case .filled:
            DesignChipPalette(
                background: SemanticColor.fill.accent.vivid,
                border: nil,
                content: ThemedColor.fixed(PrimitiveColor.neutral._1200),
                icon: ThemedColor.fixed(PrimitiveColor.neutral._1300)
            )
        case .pill:
            pillPalette(isEditing: isEditing)
        }
    }

    static func metrics(style: DesignChipStyle) -> DesignChipMetrics {
        switch style {
        case .outlined, .filled:
            DesignChipMetrics(textStyle: TextStyle.ds.caption1.medium, horizontalPadding: 14)
        case .pill:
            DesignChipMetrics(textStyle: TextStyle.ds.body.regular, horizontalPadding: 11)
        }
    }

    private static func pillPalette(isEditing: Bool) -> DesignChipPalette {
        let content = isEditing ? SemanticColor.text.accent.highlight : SemanticColor.text.neutral.tertiary
        return DesignChipPalette(
            background: SemanticColor.overlay.gray.default,
            border: nil,
            content: content,
            icon: content
        )
    }
}

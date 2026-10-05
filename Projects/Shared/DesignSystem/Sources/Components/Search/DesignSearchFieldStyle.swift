import CoreGraphics

/// 검색 칸 꼴.
public enum DesignSearchFieldStyle: Equatable, Sendable {
    /// 유리 알약형(시안 Search·Type3). 바탕은 유리 효과다.
    case glass
    /// 납작형(시안 Type4). 오른쪽에 지우기 버튼이 있다.
    case flat
}

/// 검색 칸의 색. 유리 알약형은 바탕이 nil 이다. `icon` 은 유리형 돋보기, 납작형 지우기 색이다.
struct DesignSearchFieldPalette: Equatable, Sendable {
    let background: ThemedColor?
    let text: ThemedColor
    let placeholder: ThemedColor
    let icon: ThemedColor
}

/// 검색 칸의 치수. `cornerRadius` 가 nil 이면 캡슐이다.
struct DesignSearchFieldMetrics: Equatable, Sendable {
    let height: CGFloat
    let horizontalPadding: CGFloat
    let spacing: CGFloat
    let cornerRadius: CGFloat?

    static let iconSize: CGFloat = CGFloat.ds.iconSize._18
}

/// Figma search Bar 의 꼴별 색과 치수.
/// 유리 알약형 시안은 placeholder 와 입력값이 같은 `text/neutral/primary` 다(시안 대조에서 확인한다).
enum DesignSearchFieldStyleResolver {
    static let cursor = SemanticColor.text.accent.default

    static func palette(_ style: DesignSearchFieldStyle) -> DesignSearchFieldPalette {
        switch style {
        case .glass:
            DesignSearchFieldPalette(
                background: nil,
                text: SemanticColor.text.neutral.primary,
                placeholder: SemanticColor.text.neutral.primary,
                icon: SemanticColor.text.neutral.primary
            )
        case .flat:
            DesignSearchFieldPalette(
                background: SemanticColor.fill.neutral.subtle,
                text: SemanticColor.text.neutral.primary,
                placeholder: SemanticColor.text.neutral.tertiary,
                icon: SemanticColor.text.neutral.subtle
            )
        }
    }

    static func metrics(_ style: DesignSearchFieldStyle) -> DesignSearchFieldMetrics {
        switch style {
        case .glass:
            DesignSearchFieldMetrics(
                height: 44,
                horizontalPadding: CGFloat.ds.spacing.md,
                spacing: 6,
                cornerRadius: nil
            )
        case .flat:
            DesignSearchFieldMetrics(
                height: 34,
                horizontalPadding: CGFloat.ds.spacing.md,
                spacing: CGFloat.ds.spacing.lg,
                cornerRadius: CGFloat.ds.radius._4
            )
        }
    }
}

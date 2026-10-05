import SwiftUI
import UIKit

/// 입력 칸 한 상태. 시안의 입력 전(before)·입력 중(In progress)·입력 뒤(after).
enum DesignInputPhase: Equatable, Sendable {
    case empty
    case editing
    case filled

    /// 입력 중은 포커스로 정해지고 값보다 앞선다.
    init(isEditing: Bool, isEmpty: Bool) {
        if isEditing {
            self = .editing
        } else if isEmpty {
            self = .empty
        } else {
            self = .filled
        }
    }
}

/// 입력 칸 한 상태의 색. 테두리·바탕이 없는 꼴(캡션)은 nil 이다.
struct DesignInputPalette: Equatable, Sendable {
    let border: ThemedColor?
    let background: ThemedColor?
    let text: ThemedColor
    let placeholder: ThemedColor
}

/// Figma Input 의 상태별 색. 필수 `*` 는 Figma 에 의미 색이 없어 원시 빨강을 쓴다.
enum DesignInputStyleResolver {
    static let label = SemanticColor.text.neutral.primary
    static let required = ThemedColor.fixed(PrimitiveColor.system.red)
    static let tint = SemanticColor.text.accent.default
    static let counter = SemanticColor.text.neutral.faint
    static let chevron = SemanticColor.text.neutral.primary

    /// 한 줄·여러 줄·드롭다운 칸.
    static func field(_ phase: DesignInputPhase) -> DesignInputPalette {
        let isEditing = phase == .editing
        return DesignInputPalette(
            border: isEditing ? SemanticColor.border.neutral._50 : SemanticColor.border.neutral._20,
            background: SemanticColor.fill.neutral.default,
            text: isEditing ? SemanticColor.text.neutral.primary : SemanticColor.text.neutral.secondary,
            placeholder: SemanticColor.text.neutral.subtle
        )
    }

    /// 캡션 칸. 테두리·바탕이 없고 상태에 따라 바뀌지 않는다.
    static let caption = DesignInputPalette(
        border: nil,
        background: nil,
        text: SemanticColor.text.neutral.primary,
        placeholder: SemanticColor.text.neutral.tertiary
    )
}

/// Figma Input 의 치수. 토큰이 없는 값을 여기 둔다.
/// 시안 안에서 어긋나는 여백(11·12)은 다수 쪽(위 11, 좌우 12)으로 맞췄다.
enum DesignInputMetrics {
    static let fieldHeight: CGFloat = 46
    static let labelSpacing: CGFloat = 10
    static let cellSpacing: CGFloat = 6
    static let cellContentSpacing: CGFloat = 6
    static let horizontalPadding: CGFloat = CGFloat.ds.spacing.md
    static let chevronSize: CGFloat = CGFloat.ds.iconSize._18
    static let cornerRadius: CGFloat = CGFloat.ds.radius._8
    /// 필수 표시 `*`. Pretendard Medium 16/20, 자간 +2%. 글자 스타일 토큰에 없다.
    static let requiredMarkStyle = TextStyle(
        fontName: DesignSystemFontName.medium,
        size: 16,
        lineHeight: 20,
        letterSpacingEm: 0.02
    )
}

/// 여러 줄·캡션 꼴별 높이·글자 둘레·글자 수 자리.
/// 글자 수 한 줄(14)은 칸 오른쪽 아래에서 `counterTrailing`·`counterBottom` 만큼 떨어지고, 글자 둘레 아래는 그 줄을 비켜 간다.
struct DesignTextAreaLayout: Equatable, Sendable {
    let height: CGFloat
    let textInsets: UIEdgeInsets
    let textStyle: TextStyle
    let placeholderStyle: TextStyle
    let counterTrailing: CGFloat
    let counterBottom: CGFloat

    private static let counterLineHeight: CGFloat = TextStyle.ds.caption2.medium.lineHeight
    private static let counterBottomInset: CGFloat = 14
    private static let captionCounterSpacing: CGFloat = CGFloat.ds.spacing.sm

    static func of(_ style: DesignTextAreaStyle) -> DesignTextAreaLayout {
        switch style {
        case .standard:
            DesignTextAreaLayout(
                height: 113,
                textInsets: UIEdgeInsets(
                    top: 11,
                    left: CGFloat.ds.spacing.md,
                    bottom: counterBottomInset + counterLineHeight,
                    right: CGFloat.ds.spacing.md
                ),
                textStyle: TextStyle.ds.body.regular,
                placeholderStyle: TextStyle.ds.body.regular,
                counterTrailing: 12,
                counterBottom: counterBottomInset
            )
        case .caption:
            DesignTextAreaLayout(
                height: 127,
                textInsets: UIEdgeInsets(
                    top: CGFloat.ds.spacing.md,
                    left: CGFloat.ds.spacing.lg,
                    bottom: CGFloat.ds.spacing.md + captionCounterSpacing + counterLineHeight,
                    right: CGFloat.ds.spacing.lg
                ),
                textStyle: TextStyle.ds.subtext.regular,
                placeholderStyle: TextStyle.ds.subtext.regular,
                counterTrailing: 8,
                counterBottom: counterBottomInset
            )
        }
    }
}

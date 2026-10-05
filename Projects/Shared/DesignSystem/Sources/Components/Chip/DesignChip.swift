import SwiftUI

/// 칩. 테두리형·채움형은 `onClose` 를 넘기면 닫기 아이콘을 그린다. 알약형은 `isEditing` 으로 글자색이 바뀐다.
public struct DesignChip: View {
    private let title: String
    private let style: DesignChipStyle
    private let isEditing: Bool
    private let onClose: (@MainActor () -> Void)?
    private let action: (@MainActor () -> Void)?

    /// 누르지 않는 칩. 테두리형·채움형은 `onClose` 가 있으면 닫기 아이콘을 그리고 그 아이콘이 눌린다.
    /// 알약형에는 닫기 아이콘을 그리지 않는다.
    public init(_ title: String, style: DesignChipStyle, onClose: (@MainActor () -> Void)? = nil) {
        self.title = title
        self.style = style
        isEditing = false
        self.onClose = onClose
        action = nil
    }

    /// 눌리는 칩. 알약형은 편집 중 아님도 눌린다.
    public init(
        _ title: String,
        style: DesignChipStyle,
        isEditing: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.style = style
        self.isEditing = isEditing
        onClose = nil
        self.action = action
    }

    public var body: some View {
        if let action {
            Button(action: action) {
                chip
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(style == .pill && isEditing ? .isSelected : [])
        } else {
            chip
        }
    }

    private var chip: some View {
        let palette = DesignChipStyleResolver.palette(style: style, isEditing: isEditing)
        let metrics = DesignChipStyleResolver.metrics(style: style)
        let shape = Capsule(style: .circular)
        return HStack(spacing: DesignChipMetrics.spacing) {
            DesignText(title, style: metrics.textStyle, color: palette.content.color, lineLimit: 1)
            if let onClose, style != .pill {
                Button(action: onClose) {
                    Image.ds.icon.close.outlined
                        .iconSize(DesignChipMetrics.closeIconSize)
                        .foregroundStyle(palette.icon.color)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(title) 지우기")
            }
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.vertical, DesignChipMetrics.verticalPadding)
        .frame(height: DesignChipMetrics.height)
        .background {
            if let background = palette.background {
                shape.fill(background.color)
            }
        }
        .overlay {
            if let border = palette.border {
                shape.strokeBorder(border.color, lineWidth: CGFloat.ds.border.thin)
            }
        }
        .contentShape(shape)
    }
}

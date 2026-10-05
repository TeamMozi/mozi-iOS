import SwiftUI

/// 입력 칸 위 라벨 줄. 필수면 라벨 옆에 원시 빨강 `*` 를 붙인다.
/// 줄 높이를 22 로 못 박는다. 그대로 두면 22.33 으로 그려져 아래 칸이 시안보다 내려간다.
struct DesignInputLabel: View {
    let title: String
    let isRequired: Bool

    private static let style = TextStyle.ds.headline.medium

    var body: some View {
        HStack(spacing: 0) {
            DesignText(
                title,
                style: Self.style,
                color: DesignInputStyleResolver.label.color,
                lineLimit: 1
            )
            if isRequired {
                DesignText(
                    "*",
                    style: DesignInputMetrics.requiredMarkStyle,
                    color: DesignInputStyleResolver.required.color
                )
            }
        }
        .frame(height: Self.style.lineHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isRequired ? "\(title), 필수" : title)
    }
}

extension View {
    /// 입력 칸 상자. 높이를 고정하고 상태 색으로 바탕과 안쪽 테두리 1 을 그린다. 상자 전체가 눌리는 영역이다.
    func designInputBox(_ palette: DesignInputPalette, height: CGFloat, alignment: Alignment) -> some View {
        let shape = RoundedRectangle(cornerRadius: DesignInputMetrics.cornerRadius, style: .continuous)
        return frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: alignment)
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

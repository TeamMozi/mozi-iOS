import SharedDesignSystem
import SwiftUI

/// Figma `Category Div` (`296:2868`). 그림 칸과 이름. 고르면 테두리와 이름이 강조색이 된다.
struct InterestCell: View {
    let name: String
    let image: Image
    let isSelected: Bool

    var body: some View {
        VStack(spacing: InterestCellMetrics.spacing) {
            tile

            DesignText(
                name,
                style: TextStyle.ds.caption1.medium,
                color: isSelected ? Color.ds.text.accent.default : Color.ds.text.neutral.secondary,
                alignment: .center
            )
            .frame(maxWidth: .infinity)
        }
        .frame(width: InterestCellMetrics.tileSize)
        .frame(minHeight: InterestCellMetrics.minHeight, alignment: .top)
    }

    private var tile: some View {
        // 그림은 원래 크기(70×70)로 70 칸 가운데에 둔다. 여행 그림만 70×73 이라 칸 위아래로 1.5pt 씩 넘친다(시안과 같다)
        image
            .frame(width: InterestCellMetrics.imageSize, height: InterestCellMetrics.imageSize)
            .frame(width: InterestCellMetrics.tileSize, height: InterestCellMetrics.tileSize)
            .background {
                ZStack {
                    Color.ds.fill.neutral.subtle
                    if isSelected {
                        Color.ds.overlay.inverse._10
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: InterestCellMetrics.cornerRadius))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: InterestCellMetrics.cornerRadius)
                        .strokeBorder(Color.ds.text.accent.default, lineWidth: InterestCellMetrics.selectedBorderWidth)
                }
            }
    }
}

private enum InterestCellMetrics {
    static let tileSize: CGFloat = 90
    static let imageSize: CGFloat = 70
    static let cornerRadius = CGFloat.ds.radius._24
    static let selectedBorderWidth = CGFloat.ds.border.thick
    /// 그림 칸 아래 ~ 이름
    static let spacing = CGFloat.ds.spacing.sm
    /// 시안 칸 높이. 이름이 한 줄이면 116 이지만 시안 칸 대부분이 118 고정이다
    static let minHeight: CGFloat = 118
}

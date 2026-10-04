import MoziDemoKit
import SharedDesignSystem
import SwiftUI

/// 색 화면. Figma 의미 색 묶음 17개, 칸 63개.
struct ColorGalleryView: View {
    var body: some View {
        GalleryPage(.color) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xxl) {
                ForEach(GalleryCatalog.colorGroups) { group in
                    SwatchGroup(group: group)
                }
            }
        }
    }
}

/// Figma 묶음 하나. 제목 아래에 칸을 세 줄씩 놓고, 칸 아래에 묶음 이름을 뺀 마지막 낱말을 적는다.
private struct SwatchGroup: View {
    let group: GalleryColorGroup

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: CGFloat.ds.spacing.sm, alignment: .top),
        count: ColorGalleryLayout.swatchColumns
    )

    var body: some View {
        GallerySection(group.title) {
            LazyVGrid(columns: columns, alignment: .leading, spacing: CGFloat.ds.spacing.md) {
                ForEach(group.swatches) { swatch in
                    VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                        // 투명한 색도 칸이 보이도록 모든 칸에 테두리를 두른다.
                        RoundedRectangle(cornerRadius: CGFloat.ds.radius._8, style: .continuous)
                            .fill(swatch.color)
                            .frame(height: ColorGalleryLayout.swatchHeight)
                            .overlay {
                                RoundedRectangle(cornerRadius: CGFloat.ds.radius._8, style: .continuous)
                                    .strokeBorder(Color.ds.border.neutral._40, lineWidth: CGFloat.ds.border.thin)
                            }
                        DesignText(
                            swatch.shortName,
                            style: TextStyle.ds.caption2.regular,
                            color: Color.ds.text.neutral.tertiary
                        )
                    }
                }
            }
        }
    }
}

private enum ColorGalleryLayout {
    static let swatchColumns = 3
    static let swatchHeight: CGFloat = 44
}

#Preview("색") {
    ColorGalleryView()
}

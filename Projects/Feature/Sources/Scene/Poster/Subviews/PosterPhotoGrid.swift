import SharedDesignSystem
import SwiftUI

/// 사진 시트의 3열 격자. 칸은 3:4 를 꽉 채운다.
struct PosterPhotoGrid<Cell: View>: View {
    private let count: Int
    private let cell: (Int) -> Cell

    init(count: Int, @ViewBuilder cell: @escaping (Int) -> Cell) {
        self.count = count
        self.cell = cell
    }

    var body: some View {
        LazyVGrid(columns: PosterPhotoGridLayout.columns, spacing: CGFloat.ds.spacing.sm) {
            ForEach(0..<count, id: \.self) { index in
                Color.ds.fill.neutral.subtle
                    .aspectRatio(3 / 4, contentMode: .fit)
                    .overlay {
                        cell(index)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._4))
            }
        }
    }
}

private enum PosterPhotoGridLayout {
    static let columns = Array(repeating: GridItem(.flexible(), spacing: CGFloat.ds.spacing.sm), count: 3)
}

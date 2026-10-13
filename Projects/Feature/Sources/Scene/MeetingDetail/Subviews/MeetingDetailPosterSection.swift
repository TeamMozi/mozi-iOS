import SharedDesignSystem
import SwiftUI

/// 포스터와 그 아래 아이콘 버튼 셋(채팅·필름·시리즈). 시리즈에 묶이지 않은 모임은 시리즈 버튼이 꺼진다.
struct MeetingDetailPosterSection: View {
    let posterURL: URL?
    let isSeriesEnabled: Bool
    let onChat: @MainActor () -> Void
    let onFilm: @MainActor () -> Void
    let onSeries: @MainActor () -> Void

    var body: some View {
        VStack(spacing: MeetingDetailPosterLayout.spacing) {
            poster
                .frame(width: MeetingDetailPosterLayout.posterWidth, height: MeetingDetailPosterLayout.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._16))
            HStack(spacing: CGFloat.ds.spacing.md) {
                Button("채팅", icon: Image.ds.icon.chat.filled, action: onChat)
                Button("필름", icon: Image.ds.icon.video.filled, action: onFilm)
                Button("시리즈", icon: Image.ds.icon.layers.filled, action: onSeries)
                    .disabled(!isSeriesEnabled)
            }
            .buttonStyle(.shortcut(.tile))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, CGFloat.ds.layout.margin)
    }

    private var poster: some View {
        AsyncImage(url: posterURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        ZStack {
            Color.ds.fill.neutral.subtle
            Image.ds.brand.logo
        }
    }
}

private enum MeetingDetailPosterLayout {
    static let spacing: CGFloat = 14
    static let posterWidth: CGFloat = 264
    static let posterHeight: CGFloat = 352
}

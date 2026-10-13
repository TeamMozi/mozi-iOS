import Domain
import SharedDesignSystem
import SwiftUI

/// 시리즈에 묶인 모임의 시리즈 소개와 회차 카드. 「더보기 >」 는 아직 보이기만 한다.
struct MeetingDetailSeriesSection: View {
    let series: Series
    let episodes: [Meeting]
    /// 테스트가 AsyncImage 를 기다리지 않고 포스터 자리에 그림을 바로 넣는 길. 화면은 넘기지 않는다
    var fixedPoster: Image?

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            MeetingDetailSectionTitle(title: "시리즈 소개", onMore: {})
                .padding(.horizontal, CGFloat.ds.layout.margin)
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.md) {
                introduction
                    .padding(.horizontal, CGFloat.ds.layout.margin)
                Rectangle()
                    .fill(Color.ds.border.neutral._30)
                    .frame(height: CGFloat.ds.border.thin)
                    .padding(.horizontal, CGFloat.ds.layout.margin)
                if !episodes.isEmpty {
                    // 회차가 셋보다 적어도 카드는 줄의 3등분 폭이다. 빈 칸이 남은 자리를 채운다.
                    HStack(alignment: .top, spacing: CGFloat.ds.spacing.sm) {
                        ForEach(visibleEpisodes, id: \.id) { episode in
                            MeetingDetailEpisodeCard(episode: episode, fixedPoster: fixedPoster)
                        }
                        ForEach(0..<emptySlotCount, id: \.self) { _ in
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 0)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(.vertical, MeetingDetailSeriesLayout.cardRowVerticalPadding)
                    .padding(.horizontal, CGFloat.ds.layout.margin)
                }
            }
        }
    }

    private var visibleEpisodes: ArraySlice<Meeting> {
        episodes.prefix(MeetingDetailSeriesLayout.visibleEpisodeCount)
    }

    private var emptySlotCount: Int {
        MeetingDetailSeriesLayout.visibleEpisodeCount - visibleEpisodes.count
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
            DesignText(series.title, style: TextStyle.ds.title3.semiBold)
            if let intro = series.intro, !intro.isEmpty {
                DesignText(intro, style: TextStyle.ds.body.regular, color: Color.ds.text.neutral.secondary)
            }
            MeetingDetailDotSeparatedText(
                parts: MeetingDisplayFormat.seriesSummaryParts(series),
                accessibilityLabel: MeetingDisplayFormat.seriesSummary(series),
                style: TextStyle.ds.caption1.regular,
                color: Color.ds.text.neutral.subtle
            )
            .frame(height: MeetingDetailSeriesLayout.summaryHeight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 회차 카드. 포스터 아래쪽 띠에 날짜와 요일, 카드 아래에 회차와 상태를 둔다.
private struct MeetingDetailEpisodeCard: View {
    let episode: Meeting
    let fixedPoster: Image?

    var body: some View {
        VStack(spacing: MeetingDetailSeriesLayout.cardSpacing) {
            // 카드 폭은 줄의 3등분이 정하고 포스터 칸은 3:4 다(390 폭에서 114×152).
            // 포스터는 그 칸 위에 얹어 잘라서 어떤 비율이어도 카드를 넓히지 않는다.
            posterLayer
                .aspectRatio(MeetingDetailSeriesLayout.posterAspectRatio, contentMode: .fit)
                .overlay { bandBackdrop }
                .overlay(alignment: .bottom) { dateBand }
                .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._16))
            HStack(spacing: CGFloat.ds.spacing.xs) {
                if let number = episode.episode?.number {
                    DesignText(
                        MeetingDisplayFormat.episodeNumber(number),
                        style: TextStyle.ds.caption1.medium,
                        color: Color.ds.text.neutral.tertiary,
                        lineLimit: 1
                    )
                }
                DesignText(
                    MeetingDisplayFormat.episodeStatusTitle(episode.status),
                    style: TextStyle.ds.caption1.medium,
                    color: statusColor,
                    lineLimit: 1
                )
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var statusColor: Color {
        switch episode.status {
        case .recruiting: Color.ds.text.status.positive
        case .closed: Color.ds.text.neutral.subtle
        case .ended: Color.ds.text.status.negative
        }
    }

    @ViewBuilder
    private var poster: some View {
        if let fixedPoster {
            fixedPoster
                .resizable()
                .scaledToFill()
        } else {
            AsyncImage(url: episode.posterURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                }
            }
        }
    }

    /// 포스터 칸의 바탕과 포스터. 날짜 띠 뒤의 흐린 그림도 이 층을 그대로 다시 그린다.
    private var posterLayer: some View {
        Color.ds.fill.neutral.subtle
            .overlay { poster }
            .clipped()
    }

    /// 시안 띠의 BACKGROUND_BLUR 8. 포스터 층을 같은 크기로 한 번 더 그려 흐리고 띠 자리만 남긴다.
    /// `opaque: true` 라 가장자리가 투명하게 빠지지 않고 칸 끝 화소를 늘려 흐린다.
    private var bandBackdrop: some View {
        posterLayer
            .blur(radius: MeetingDetailSeriesLayout.bandBlurRadius, opaque: true)
            .mask(alignment: .bottom) {
                Rectangle()
                    .frame(height: MeetingDetailSeriesLayout.bandHeight)
            }
    }

    /// 포스터 위 날짜 띠. 시안은 두 모드 모두 검정 60%(`overlay/dark/60`) 위에 흰 날짜와 밝은 회색 요일이다.
    /// 그 색이 두 모드에서 같도록 다크 모드 색을 빌려 온다. 모서리는 포스터 칸이 잘라 준다.
    private var dateBand: some View {
        HStack(spacing: CGFloat.ds.spacing.xs) {
            DesignText(
                MeetingDisplayFormat.episodeDay(episode.startAt),
                style: TextStyle.ds.title3.semiBold,
                lineLimit: 1
            )
            DesignText(
                MeetingDisplayFormat.episodeWeekday(episode.startAt),
                style: TextStyle.ds.caption2.medium,
                color: Color.ds.text.neutral.secondary,
                lineLimit: 1
            )
        }
        .padding(.horizontal, MeetingDetailSeriesLayout.bandPadding)
        .frame(maxWidth: .infinity)
        .frame(height: MeetingDetailSeriesLayout.bandHeight)
        .background(Color.ds.overlay.dim._60)
        .environment(\.colorScheme, .dark)
    }
}

private enum MeetingDetailSeriesLayout {
    static let visibleEpisodeCount = 3
    static let summaryHeight: CGFloat = 20
    static let cardRowVerticalPadding: CGFloat = 6
    static let cardSpacing: CGFloat = 10
    /// 시안 회차 포스터 114×152
    static let posterAspectRatio: CGFloat = 3.0 / 4.0
    static let bandPadding: CGFloat = 6
    /// 시안 띠 114×36. 위아래 여백 6 + 날짜 한 줄(title3 줄 높이 24) + 6
    static let bandHeight: CGFloat = 36
    /// 시안 BACKGROUND_BLUR 반경 8 의 절반. Figma 반경은 가우스 표준편차의 두 배, SwiftUI 반경은 표준편차다
    static let bandBlurRadius: CGFloat = 4
}

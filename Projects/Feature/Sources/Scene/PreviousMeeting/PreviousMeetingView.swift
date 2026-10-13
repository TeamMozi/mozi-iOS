import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct PreviousMeetingView: View {
    @Bindable public var store: StoreOf<PreviousMeetingFeature>

    public init(store: StoreOf<PreviousMeetingFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                DesignText("다시 열고 싶은 모임을 선택해주세요.", style: TextStyle.ds.caption1.regular, alignment: .center)
                    .padding(.top, CGFloat.ds.spacing.xs)
                    .padding(.bottom, CGFloat.ds.spacing.lg)
                tabs
                    .padding(.bottom, PreviousMeetingLayout.tabsToList)
                Group {
                    switch store.tab {
                    case .latest:
                        latestList
                    case .series:
                        seriesList
                    }
                }
                .padding(.vertical, CGFloat.ds.spacing.sm)
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
            .padding(.bottom, PreviousMeetingLayout.bottomInset)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DesignToolbarTitle("모임 불러오기")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.nextTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.arrows.right, isProminent: true)
                }
                .designToolbarProminent()
                .disabled(store.selectedMeetingID == nil)
                .accessibilityLabel("다음")
            }
        }
        .task {
            store.send(.task)
        }
        .screenStatus(
            store.screen,
            onRetry: { store.send(.retryTapped) },
            onDismiss: { store.send(.failureDismissed) }
        )
    }

    private var tabs: some View {
        HStack(spacing: PreviousMeetingLayout.tabSpacing) {
            tabButton("시리즈별", tab: .series)
            tabButton("최신순", tab: .latest)
        }
    }

    @ViewBuilder
    private func tabButton(_ title: String, tab: PreviousMeetingFeature.Tab) -> some View {
        if store.tab == tab {
            Button(title) {
                store.send(.tabSelected(tab))
            }
            .buttonStyle(.pill)
            .accessibilityAddTraits(.isSelected)
        } else {
            Button {
                store.send(.tabSelected(tab))
            } label: {
                DesignText(title, style: TextStyle.ds.subtext.medium, color: Color.ds.text.neutral.subtle)
                    .padding(.horizontal, CGFloat.ds.spacing.md)
                    .frame(height: PreviousMeetingLayout.tabHeight)
            }
            .buttonStyle(.plain)
        }
    }

    private var latestList: some View {
        LazyVStack(spacing: CGFloat.ds.spacing.lg) {
            ForEach(store.latest, id: \.id) { meeting in
                meetingButton(meeting)
                    .onAppear {
                        if meeting.id == store.latest.last?.id {
                            store.send(.lastMeetingAppeared)
                        }
                    }
            }
        }
    }

    private var seriesList: some View {
        LazyVStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
            ForEach(store.hostedSeries, id: \.series.id) { hosted in
                seriesSection(hosted)
                    .onAppear {
                        if hosted.series.id == store.hostedSeries.last?.series.id {
                            store.send(.lastSeriesAppeared)
                        }
                    }
            }
        }
    }

    private func seriesSection(_ hosted: HostedSeries) -> some View {
        let isExpanded = store.expandedSeriesIDs.contains(hosted.series.id)
        return VStack(alignment: .leading, spacing: CGFloat.ds.spacing.md) {
            SeriesFoldRow(hosted: hosted, isExpanded: isExpanded) {
                store.send(.seriesToggled(hosted.series.id))
            }
            if isExpanded {
                VStack(spacing: CGFloat.ds.spacing.lg) {
                    ForEach(store.state.episodes(of: hosted), id: \.id) { meeting in
                        meetingButton(meeting)
                    }
                    if store.state.canLoadMoreEpisodes(of: hosted) {
                        Button {
                            store.send(.moreEpisodesTapped(hosted.series.id))
                        } label: {
                            Text("이 시리즈 모임 더보기")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.neutral)
                        .controlSize(.small)
                    }
                }
            }
        }
    }

    private func meetingButton(_ meeting: Meeting) -> some View {
        Button {
            store.send(.meetingTapped(meeting.id))
        } label: {
            PreviousMeetingCard(meeting: meeting, isSelected: store.selectedMeetingID == meeting.id)
        }
        .buttonStyle(.plain)
    }
}

private enum PreviousMeetingLayout {
    /// 탭 두 칸 사이
    static let tabSpacing: CGFloat = 6
    /// 탭 칸 높이. Figma btn_text
    static let tabHeight: CGFloat = 32
    /// 탭 아래에서 목록 틀까지. 목록 틀 안 위 여백 8 이 더해진다
    static let tabsToList: CGFloat = 10
    /// 목록 아래 여백
    static let bottomInset: CGFloat = 60
}

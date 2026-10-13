import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct MeetingDetailView: View {
    @Bindable public var store: StoreOf<MeetingDetailFeature>
    /// 가입 질문 시트가 잰 내용 높이. 재기 전에는 medium 으로 띄운다.
    @State private var joinSheetHeight: CGFloat?

    public init(store: StoreOf<MeetingDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .designSheet(isPresented: isJoinSheetPresented, detents: [joinSheetDetent]) {
                JoinQuestionSheet(store: store) { height in
                    joinSheetHeight = height
                }
            }
            .screenStatus(
                store.screen,
                onRetry: { store.send(.retryTapped) },
                onDismiss: { store.send(.failureDismissed) }
            )
            .task {
                store.send(.task)
            }
    }

    @ViewBuilder
    private var content: some View {
        if store.canApply || store.perspective == .pending {
            sections
                .bottomButtonArea {
                    MeetingDetailBottomArea(store: store)
                }
        } else {
            sections
        }
    }

    private var sections: some View {
        ScrollView {
            if let meeting = store.meeting {
                VStack(spacing: MeetingDetailLayout.topToSections) {
                    VStack(spacing: MeetingDetailLayout.posterToSummary) {
                        MeetingDetailPosterSection(
                            posterURL: meeting.posterURL,
                            isSeriesEnabled: store.isSeriesEnabled,
                            onChat: { store.send(.chatTapped) },
                            onFilm: { store.send(.filmTapped) },
                            onSeries: { store.send(.seriesTapped) }
                        )
                        MeetingDetailSummarySection(meeting: meeting)
                    }
                    VStack(spacing: MeetingDetailLayout.sectionSpacing) {
                        MeetingDetailTextSection(title: "모임 소개", text: meeting.intro)
                        MeetingDetailTextSection(title: "상세 정보", text: meeting.detail)
                        if store.showsSnapPoints {
                            MeetingDetailSnapPointSection(snapPoints: store.snapPoints)
                        }
                        if let series = store.series {
                            MeetingDetailSeriesSection(series: series, episodes: store.episodes)
                        }
                        MeetingDetailHostSection(host: meeting.host)
                        MeetingDetailMemberSection(members: store.members)
                    }
                }
                .padding(.vertical, CGFloat.ds.spacing.sm)
                .padding(.top, MeetingDetailLayout.headerToContent)
            }
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                store.send(.backTapped)
            } label: {
                DesignToolbarIcon(Image.ds.icon.chevron.left)
            }
            .accessibilityLabel("뒤로")
        }
        ToolbarItem(placement: .principal) {
            DesignToolbarTitle("모임 상세")
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                store.send(.bellTapped)
            } label: {
                DesignToolbarIcon(
                    store.meeting?.isNotificationRequested == true
                        ? Image.ds.icon.bell.filled
                        : Image.ds.icon.bell.outlined
                )
            }
            .accessibilityLabel("알림 요청")
        }
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        ToolbarItem(placement: .topBarTrailing) {
            MeetingDetailMoreButton(store: store)
        }
    }

    private var joinSheetDetent: PresentationDetent {
        joinSheetHeight.map { .height($0) } ?? .medium
    }

    private var isJoinSheetPresented: Binding<Bool> {
        Binding(
            get: { store.joinAnswers != nil },
            set: { isPresented in
                if !isPresented {
                    store.send(.joinSheetDismissed)
                }
            }
        )
    }
}

/// 위 오른쪽 둘째 버튼. 모임장은 `≡`(모임 관리), 멤버는 `•••` →「모임 나가기」, 승인 대기는 `•••` →「신청 취소」,
/// 신청 전은 `•••` 가 아무것도 하지 않는다.
struct MeetingDetailMoreButton: View {
    let store: StoreOf<MeetingDetailFeature>

    var body: some View {
        switch store.perspective {
        case .host?:
            Button {
                store.send(.menuTapped)
            } label: {
                DesignToolbarIcon(Image.ds.icon.menu.outlined)
            }
            .accessibilityLabel("모임 관리")
        case .member?:
            leaveMenu(title: "모임 나가기")
        case .pending?:
            leaveMenu(title: "신청 취소")
        case .some(MyParticipation.none), nil:
            Button {} label: {
                DesignToolbarIcon(Image.ds.icon.moreHorizontal.outlined)
            }
            .accessibilityLabel("더보기")
        }
    }

    private func leaveMenu(title: String) -> some View {
        Menu {
            Button(title, role: .destructive) {
                store.send(.leaveTapped)
            }
        } label: {
            DesignToolbarIcon(Image.ds.icon.moreHorizontal.outlined)
        }
        .accessibilityLabel("더보기")
    }
}

private enum MeetingDetailLayout {
    /// 시안은 헤더 끝(99)과 본문 사이에 9 를 더 둔다. 본문 위 여백 8 과 합쳐 포스터가 헤더 끝 17 아래에 온다
    static let headerToContent: CGFloat = 9
    static let posterToSummary: CGFloat = 22
    static let topToSections: CGFloat = CGFloat.ds.spacing.xl
    static let sectionSpacing: CGFloat = 44
}

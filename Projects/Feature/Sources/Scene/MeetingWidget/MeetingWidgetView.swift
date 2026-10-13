import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct MeetingWidgetView: View {
    @Bindable public var store: StoreOf<MeetingWidgetFeature>

    public init(store: StoreOf<MeetingWidgetFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            if let meeting = store.meeting {
                VStack(spacing: MeetingWidgetLayout.sectionSpacing) {
                    VStack(spacing: CGFloat.ds.spacing.xl) {
                        WidgetHeader(meeting: meeting)
                        VStack(spacing: CGFloat.ds.spacing.lg) {
                            WidgetTiles(isMemberGridShown: store.isMemberGridShown) {
                                store.send(.memberTileTapped)
                            }
                            if store.isMemberGridShown {
                                WidgetMemberGrid(members: store.members) {
                                    store.send(.memberAllTapped)
                                }
                            }
                        }
                    }
                    snapPointList
                }
                .padding(.top, MeetingWidgetLayout.topInset)
                .padding(.horizontal, MeetingWidgetLayout.horizontalInset)
                .padding(.bottom, CGFloat.ds.spacing.xl)
            }
        }
        // 시안은 포스터를 화면 맨 위에서 80 아래에 둔다. 툴바 버튼과 겹쳐 보이는 것까지 시안 그대로다.
        .ignoresSafeArea(.container, edges: .top)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.closeTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.close.outlined)
                }
                .accessibilityLabel("닫기")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    // 시안 메뉴는 「모임 종료」 를 다른 항목과 같은 기본 글자색으로 그린다. 되돌릴 수 없음은 확인 창이 알린다
                    // 모집 중이면 감춘다. 모집 마감을 거쳐야 종료한다
                    if store.isEndMenuShown {
                        Button("모임 종료") { store.send(.endMenuTapped) }
                            .disabled(!store.canEnd)
                    }
                    Button("스냅포인트 편집") { store.send(.editMenuTapped) }
                        .disabled(!store.canManage)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.moreHorizontal.outlined)
                }
                .accessibilityLabel("더보기")
            }
        }
        .alert(
            MeetingConfirmationCopy.endTitle,
            isPresented: Binding(get: { store.isEndConfirmationPresented }, set: { _ in })
        ) {
            Button(MeetingConfirmationCopy.endButton, role: .destructive) { store.send(.endConfirmed) }
            Button(MeetingConfirmationCopy.cancelButton, role: .cancel) { store.send(.endDismissed) }
        } message: {
            Text(MeetingConfirmationCopy.endMessage)
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

    private var snapPointList: some View {
        VStack(spacing: MeetingWidgetLayout.rowSpacing) {
            ForEach(store.snapPoints) { snapPoint in
                WidgetSnapPointRow(
                    snapPoint: snapPoint,
                    members: store.members,
                    participantCount: store.state.shownParticipantCount(snapPoint),
                    canNotify: store.state.canNotify(snapPoint),
                    isSending: store.sendingSnapPointID == snapPoint.id,
                    onNotify: { store.send(.notifyTapped(id: snapPoint.id)) }
                )
            }
        }
    }
}

private enum MeetingWidgetLayout {
    static let topInset: CGFloat = 80
    static let horizontalInset: CGFloat = 20
    static let sectionSpacing: CGFloat = 28
    static let rowSpacing: CGFloat = 10
}

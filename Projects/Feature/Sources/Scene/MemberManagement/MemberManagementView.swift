import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct MemberManagementView: View {
    @Bindable public var store: StoreOf<MemberManagementFeature>
    /// 확인 창이 닫히는 동안 제목이 「님을 내보낼까요?」 로 바뀌지 않게 마지막 닉네임을 들고 있는다
    @State private var lastKickNickname = ""

    public init(store: StoreOf<MemberManagementFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            DesignTopTabBar(
                MemberManagementFeature.Tab.allCases,
                selection: store.tab,
                title: { $0.title },
                onSelect: { store.send(.tabSelected($0)) }
            )
            ScrollView {
                LazyVStack(spacing: MemberManagementLayout.rowSpacing) {
                    switch store.tab {
                    case .members:
                        membersTab
                    case .pending:
                        pendingTab
                    case .notificationRequesters:
                        requestersTab
                    }
                }
                .padding(.top, MemberManagementLayout.listTopPadding)
                .padding(.horizontal, CGFloat.ds.layout.margin)
            }
        }
        // 같은 덮개 안에서 사이드바와 바탕이 달라 보이지 않게 사이드바와 같은 `overlay/dim/90` 을 칠한다.
        // 뒤 상세의 흐림은 흐름 화면이 건다
        .background {
            Color.ds.overlay.dim._90
                .ignoresSafeArea()
        }
        // 사이드바(큰 제목 모드)에서 쌓여 들어와도 큰 제목 자리가 탭 위에 끼지 않게 한다. 시안 헤더는 한 줄이다
        .navigationBarTitleDisplayMode(.inline)
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
            ToolbarItem(placement: .principal) {
                DesignToolbarTitle("멤버 관리")
            }
        }
        .alert(
            MeetingConfirmationCopy.kickTitle(store.kickTarget?.nickname ?? lastKickNickname),
            isPresented: Binding(get: { store.kickTarget != nil }, set: { _ in })
        ) {
            Button(MeetingConfirmationCopy.kickButton, role: .destructive) { store.send(.kickConfirmed) }
            Button(MeetingConfirmationCopy.cancelButton, role: .cancel) { store.send(.kickDismissed) }
        }
        .onChange(of: store.kickTarget?.nickname) { _, nickname in
            if let nickname {
                lastKickNickname = nickname
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
    private var membersTab: some View {
        MemberRow(nickname: store.host.nickname, imageURL: store.host.profileImageURL) { EmptyView() }
        if store.members.isEmpty {
            MemberEmptyRow("아직 참여한 멤버가 없어요")
        }
        ForEach(store.members, id: \.userID) { member in
            MemberRow(nickname: member.nickname, imageURL: member.profileImageURL) {
                if store.showsMemberActions {
                    Button("내보내기") { store.send(.kickTapped(userID: member.userID)) }
                        .buttonStyle(.textButton(.neutral))
                        .disabled(store.requestingUserIDs.contains(member.userID))
                }
            }
        }
    }

    @ViewBuilder
    private var pendingTab: some View {
        if store.pending.isEmpty {
            MemberEmptyRow("승인을 기다리는 신청이 없어요")
        }
        ForEach(store.pending, id: \.userID) { member in
            MemberRow(nickname: member.nickname, imageURL: member.profileImageURL) {
                if store.showsMemberActions {
                    Button("승인") { store.send(.approveTapped(userID: member.userID)) }
                        .buttonStyle(.textButton(.neutral))
                        .disabled(!store.state.canApprove(member))
                }
            }
        }
    }

    @ViewBuilder
    private var requestersTab: some View {
        if store.notificationRequesters.isEmpty {
            MemberEmptyRow("알림을 요청한 사람이 없어요")
        }
        ForEach(store.notificationRequesters, id: \.userID) { member in
            MemberRow(nickname: member.nickname, imageURL: member.profileImageURL) { EmptyView() }
        }
    }
}

/// 시안 `2798:104700` 목록 틀(`Div`) 값
private enum MemberManagementLayout {
    static let listTopPadding: CGFloat = 20
    static let rowSpacing: CGFloat = CGFloat.ds.spacing.xs
}

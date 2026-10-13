import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct MeetingManagementView: View {
    @Bindable public var store: StoreOf<MeetingManagementFeature>

    public init(store: StoreOf<MeetingManagementFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.ds.spacing.lg) {
                MeetingManagementHeader(
                    meeting: store.meeting,
                    isEnded: store.isEnded,
                    onPosterEdit: { store.send(.rowTapped(.posterEdit)) },
                    onStatusSelect: { store.send(.statusSelected($0)) }
                )
                MeetingManagementGroup {
                    MeetingManagementRow("모임 정보 수정") { store.send(.rowTapped(.infoEdit)) }
                    MeetingManagementRow("멤버 관리") { store.send(.memberManagementTapped) }
                }
                MeetingManagementGroup {
                    MeetingManagementRow("스냅 포인트 설정", value: "\(store.snapPointCount)") {
                        store.send(.snapPointSettingTapped)
                    }
                    MeetingManagementRow("가입 질문") { store.send(.rowTapped(.joinQuestions)) }
                    MeetingManagementRow("가입 방식 관리", value: MeetingDisplayFormat.joinType(store.meeting.joinType)) {
                        store.send(.rowTapped(.joinType))
                    }
                    MeetingManagementRow(
                        "최대 가입 인원 설정",
                        value: MeetingDisplayFormat.capacity(store.meeting.capacity)
                    ) {
                        store.send(.rowTapped(.capacity))
                    }
                }
                MeetingManagementGroup {
                    MeetingManagementDeleteRow { store.send(.deleteTapped) }
                }
            }
            .padding(.vertical, MeetingManagementLayout.verticalPadding)
            .padding(.horizontal, CGFloat.ds.layout.margin)
        }
        // 상세를 덮는 사이드바. 바탕은 `overlay/dim/90` 만 칠한다. 뒤 상세의 흐림(시안 배경 흐림 40)은 흐름 화면이 건다.
        // 멤버 관리 바탕과 같은 값이다. 덮개 안 NavigationStack 의 바탕은 비운다.
        .background {
            Color.ds.overlay.dim._90
                .ignoresSafeArea()
        }
        .containerBackground(.clear, for: .navigation)
        // 제목 없는 첫 화면이라 기본값이면 큰 제목 칸(52pt)이 비어 내용이 그만큼 내려간다.
        .navigationBarTitleDisplayMode(.inline)
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
                DesignToolbarTitle("모임 관리")
            }
        }
        .alert(
            MeetingConfirmationCopy.endTitle,
            isPresented: confirmationBinding(.endMeeting)
        ) {
            Button(MeetingConfirmationCopy.endButton, role: .destructive) { store.send(.confirmationConfirmed) }
            Button(MeetingConfirmationCopy.cancelButton, role: .cancel) { store.send(.confirmationDismissed) }
        } message: {
            Text(MeetingConfirmationCopy.endMessage)
        }
        .alert(
            MeetingConfirmationCopy.deleteTitle,
            isPresented: confirmationBinding(.deleteMeeting)
        ) {
            Button(MeetingConfirmationCopy.deleteButton, role: .destructive) { store.send(.confirmationConfirmed) }
            Button(MeetingConfirmationCopy.cancelButton, role: .cancel) { store.send(.confirmationDismissed) }
        } message: {
            Text(MeetingConfirmationCopy.deleteMessage)
        }
        .screenStatus(store.screen, onDismiss: { store.send(.failureDismissed) })
    }

    // 표시 여부는 상태에서만 읽는다. 닫기는 버튼이 액션을 보내 상태를 바꿔서 한다.
    private func confirmationBinding(_ confirmation: MeetingManagementFeature.Confirmation) -> Binding<Bool> {
        Binding(
            get: { store.confirmation == confirmation },
            set: { _ in }
        )
    }
}

private enum MeetingManagementLayout {
    static let verticalPadding: CGFloat = 10
}

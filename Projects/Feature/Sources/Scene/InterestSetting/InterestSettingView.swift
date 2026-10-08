import Domain
import Foundation
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct InterestSettingView: View {
    @Bindable public var store: StoreOf<InterestSettingFeature>

    public init(store: StoreOf<InterestSettingFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: InterestSettingLayout.headlineToGridSpacing) {
                // 시안 줄바꿈 그대로 두 줄로 끊는다
                DesignText(
                    "관심있는 카테고리를\n한 개 이상 선택해 주세요.",
                    style: TextStyle.ds.title2.semiBold,
                    color: Color.ds.text.neutral.primary,
                    alignment: .center
                )

                LazyVGrid(columns: InterestSettingLayout.columns, spacing: InterestSettingLayout.rowSpacing) {
                    ForEach(store.interests) { interest in
                        cell(for: interest)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, InterestSettingLayout.topInset)
            .padding(.bottom, InterestSettingLayout.bottomInset)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        // 저장 중에도 뒤로 버튼은 보이되 눌리지 않는다. 시스템 버튼을 숨기기만 하면 바가 통째로 사라져 화면이 위로 뛴다
        .navigationBarBackButtonHidden(store.isSaving)
        .toolbar {
            if store.isSaving {
                ToolbarItem(placement: .topBarLeading) {
                    Button {} label: {
                        DesignToolbarIcon(Image.ds.icon.chevron.left)
                    }
                    .accessibilityLabel("뒤로")
                    .disabled(true)
                }
            }
        }
        .bottomButtonArea {
            BottomButtonArea(.single) {
                Button {
                    store.send(.completeTapped)
                } label: {
                    Text("완료")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.main)
                .controlSize(.large)
                .disabled(store.isCompleteEnabled == false)
            }
        }
        .screenStatus(
            store.screen,
            onRetry: { store.send(.retryTapped) },
            onDismiss: { store.send(.failureDismissed) }
        )
        .task {
            store.send(.onAppear)
        }
    }

    private func cell(for interest: Interest) -> some View {
        let isSelected = store.state.isSelected(interest)
        return Button {
            store.send(.interestTapped(id: interest.id))
        } label: {
            InterestCell(
                name: interest.name,
                image: InterestIcon(interestName: interest.name).image,
                isSelected: isSelected
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private enum InterestSettingLayout {
    static let columns = Array(
        repeating: GridItem(.fixed(cellWidth), spacing: columnSpacing),
        count: 3
    )
    static let cellWidth: CGFloat = 90
    static let columnSpacing = CGFloat.ds.spacing.xl
    static let rowSpacing: CGFloat = 18
    /// 헤더 아래 ~ 안내 문구. 시안은 8 이지만 시스템 바(54)가 시안 헤더(52)보다 2pt 높아 그만큼 뺀다
    static let topInset: CGFloat = 6
    /// 안내 문구 아래 ~ 격자
    static let headlineToGridSpacing: CGFloat = 29
    /// 격자 아래 ~ 하단 버튼 영역
    static let bottomInset: CGFloat = 34
}

// MARK: - Preview

private let previewDraft = OnboardingDraft(
    nickname: "수연",
    birthDate: Date(timeIntervalSince1970: 946_684_800),
    gender: .female,
    introduction: nil,
    profileImage: .keep,
    interestIDs: []
)

#Preview("InterestSetting / Idle") {
    NavigationStack {
        InterestSettingView(
            store: Store(initialState: InterestSettingFeature.State(draft: previewDraft)) {
                InterestSettingFeature()
            } withDependencies: {
                $0.interestClient = .previewValue
                $0.userClient = .previewValue
            }
        )
    }
}

#Preview("InterestSetting / Saving") {
    let interests = InterestClient.previewInterests
    NavigationStack {
        InterestSettingView(
            store: Store(
                initialState: InterestSettingFeature.State(
                    draft: previewDraft,
                    interests: interests,
                    selectedIDs: [interests[1].id, interests[5].id, interests[6].id],
                    isSaving: true,
                    screen: .loading
                )
            ) {
                InterestSettingFeature()
            }
        )
    }
}

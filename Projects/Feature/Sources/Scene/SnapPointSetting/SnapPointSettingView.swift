import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct SnapPointSettingView: View {
    @Bindable public var store: StoreOf<SnapPointSettingFeature>

    public init(store: StoreOf<SnapPointSettingFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: SnapPointSettingLayout.sectionSpacing) {
                VStack(spacing: SnapPointSettingLayout.cardSpacing) {
                    ForEach(store.snapPoints) { snapPoint in
                        SnapPointCard(
                            snapPoint: snapPoint,
                            showsMenu: store.showsCardMenu,
                            isMenuEnabled: store.canEdit,
                            canDelete: store.state.canDelete(snapPoint),
                            onEdit: { store.send(.editTapped(id: snapPoint.id)) },
                            onDelete: { store.send(.deleteTapped(id: snapPoint.id)) }
                        )
                    }
                    SnapPointAddButton(isEnabled: store.canAdd) {
                        store.send(.addTapped)
                    }
                }
                SnapPointRecommendationSection(
                    recommendations: SnapPointRecommendation.all,
                    isEnabled: store.canAdd,
                    onSelect: { store.send(.recommendationTapped($0)) }
                )
            }
            .padding(CGFloat.ds.layout.margin)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .overlay {
            if store.isHelpPresented {
                SnapPointHelpOverlay {
                    store.send(.helpDismissed)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button {
                    store.send(.helpTapped)
                } label: {
                    HStack(spacing: SnapPointSettingLayout.titleIconSpacing) {
                        DesignToolbarTitle("스냅포인트")
                        Image.ds.icon.question.outlined
                            .iconSize(CGFloat.ds.iconSize._18)
                            .foregroundStyle(Color.ds.text.neutral.faint)
                    }
                }
                .accessibilityLabel("스냅포인트 도움말")
            }
        }
        .fullScreenCover(isPresented: isEditorPresented) {
            SnapPointEditorView(store: store)
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

    private var isEditorPresented: Binding<Bool> {
        Binding(
            get: { store.editor != nil },
            set: { isPresented in
                if !isPresented {
                    store.send(.editorDismissed)
                }
            }
        )
    }
}

/// 시안 `2836:139428` 본문 틀(`Frame 1739337315`)과 헤더 제목 줄 값
private enum SnapPointSettingLayout {
    static let sectionSpacing: CGFloat = CGFloat.ds.spacing.xl
    static let cardSpacing: CGFloat = CGFloat.ds.spacing.md
    static let titleIconSpacing: CGFloat = CGFloat.ds.spacing.xs
}

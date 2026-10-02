import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct MyPagePlaceholderView: View {
    @Bindable public var store: StoreOf<MyPagePlaceholderFeature>

    public init(store: StoreOf<MyPagePlaceholderFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: CGFloat.ds.spacing.md) {
            Spacer()

            DesignText(
                "MyPage",
                style: TextStyle.ds.title2.bold,
                color: Color.ds.text.neutral.primary,
                alignment: .center
            )

            Spacer()

            if let errorMessage = store.errorMessage {
                DesignText(
                    errorMessage,
                    style: TextStyle.ds.subtext.regular,
                    color: Color.ds.text.accent.subtle,
                    alignment: .center
                )
            }

            DesignButton(
                "로그아웃",
                variant: .outlined,
                size: .lg,
                isEnabled: store.isLoggingOut == false,
                isFullWidth: true
            ) {
                store.send(.logoutTapped)
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
            .padding(.bottom, CGFloat.ds.spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .task {
            store.send(.onAppear)
        }
    }
}

// MARK: - Preview

#Preview("MyPage / Idle") {
    MyPagePlaceholderView(
        store: Store(initialState: MyPagePlaceholderFeature.State()) {
            MyPagePlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {}
        }
    )
}

#Preview("MyPage / Error") {
    MyPagePlaceholderView(
        store: Store(
            initialState: MyPagePlaceholderFeature.State(
                errorMessage: "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요."
            )
        ) {
            MyPagePlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {
                throw AuthError.storage(message: "preview-storage-error")
            }
        }
    )
}

import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct OnboardingPlaceholderView: View {
    @Bindable public var store: StoreOf<OnboardingPlaceholderFeature>

    public init(store: StoreOf<OnboardingPlaceholderFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: CGFloat.ds.spacing.md) {
            Spacer()

            DesignText(
                "추가 정보 입력이 필요해요",
                style: TextStyle.ds.title2.bold,
                color: Color.ds.text.neutral.primary,
                alignment: .center
            )

            DesignText(
                "온보딩 화면은 곧 연결될 예정이에요.",
                style: TextStyle.ds.body.regular,
                color: Color.ds.text.neutral.subtle,
                alignment: .center
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .task {
            store.send(.onAppear)
        }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingPlaceholderView(
        store: Store(initialState: OnboardingPlaceholderFeature.State()) {
            OnboardingPlaceholderFeature()
        }
    )
}

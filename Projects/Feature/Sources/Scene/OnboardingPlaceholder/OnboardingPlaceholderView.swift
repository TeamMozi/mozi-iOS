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
                style: TextStyle.ds.title.large24Bold,
                color: Color.ds.text.neutral.white,
                alignment: .center
            )

            DesignText(
                "온보딩 화면은 곧 연결될 예정이에요.",
                style: TextStyle.ds.body.medium16Regular,
                color: Color.ds.text.neutral.basic,
                alignment: .center
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.background.black.ignoresSafeArea())
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
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

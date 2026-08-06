import Domain
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

            if let errorMessage = store.errorMessage {
                DesignText(
                    errorMessage,
                    style: TextStyle.ds.body.small14Regular,
                    color: Color.ds.text.primary.basic,
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
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.bottom, CGFloat.ds.spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.background.black.ignoresSafeArea())
        .task {
            store.send(.onAppear)
        }
    }
}

// MARK: - Preview

#Preview("Onboarding / Idle") {
    OnboardingPlaceholderView(
        store: Store(initialState: OnboardingPlaceholderFeature.State()) {
            OnboardingPlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {}
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("Onboarding / Logging Out") {
    OnboardingPlaceholderView(
        store: Store(
            initialState: OnboardingPlaceholderFeature.State(
                isLoggingOut: true
            )
        ) {
            OnboardingPlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {
                try await Task.sleep(nanoseconds: 60_000_000_000)
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("Onboarding / Error") {
    OnboardingPlaceholderView(
        store: Store(
            initialState: OnboardingPlaceholderFeature.State(
                errorMessage: "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요."
            )
        ) {
            OnboardingPlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {
                throw AuthError.storage(message: "preview-storage-error")
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

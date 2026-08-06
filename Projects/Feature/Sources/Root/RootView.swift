import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct RootView: View {
    @Bindable public var store: StoreOf<RootFeature>

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    public var body: some View {
        AppCoordinatorView(
            store: store.scope(state: \.appCoordinator, action: \.appCoordinator)
        )
    }
}

// MARK: - Preview

#Preview("Root / Bootstrapping") {
    RootView(
        store: Store(
            initialState: RootFeature.State(
                appCoordinator: AppCoordinatorFeature.State(
                    phase: .bootstrapping,
                    isRestoringSession: true
                )
            )
        ) {
            RootFeature()
        } withDependencies: {
            $0.authClient.restoreSession = {
                try await Task.sleep(nanoseconds: 60_000_000_000)
                return nil
            }
        }
    )
}

#Preview("Root / Login") {
    RootView(
        store: Store(
            initialState: RootFeature.State(
                appCoordinator: AppCoordinatorFeature.State(
                    phase: .login(LoginFeature.State())
                )
            )
        ) {
            RootFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.login = { _ in
                AuthSession(
                    accessToken: "preview-access",
                    refreshToken: "preview-refresh",
                    isNewUser: false,
                    profileCompleted: true
                )
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("Root / Onboarding") {
    RootView(
        store: Store(
            initialState: RootFeature.State(
                appCoordinator: AppCoordinatorFeature.State(
                    phase: .onboarding(OnboardingPlaceholderFeature.State())
                )
            )
        ) {
            RootFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.logout = {}
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("Root / Main") {
    RootView(
        store: Store(
            initialState: RootFeature.State(
                appCoordinator: AppCoordinatorFeature.State(
                    phase: .main(PlaceholderFeature.State())
                )
            )
        ) {
            RootFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
        }
    )
}

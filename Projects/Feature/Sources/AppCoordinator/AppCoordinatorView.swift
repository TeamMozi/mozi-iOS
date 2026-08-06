import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct AppCoordinatorView: View {
    @Bindable public var store: StoreOf<AppCoordinatorFeature>

    public init(store: StoreOf<AppCoordinatorFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            switch store.phase {
            case .bootstrapping:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .login:
                if let loginStore = store.scope(state: \.login, action: \.login) {
                    LoginView(store: loginStore)
                }
            case .onboarding:
                if let onboardingStore = store.scope(state: \.onboarding, action: \.onboarding) {
                    OnboardingPlaceholderView(store: onboardingStore)
                }
            case .main:
                if let mainStore = store.scope(state: \.mainPlaceholder, action: \.main) {
                    PlaceholderView(store: mainStore)
                }
            }
        }
        .overlay {
            OverlayView(store: store.scope(state: \.overlay, action: \.overlay))
        }
        .task {
            store.send(.onAppear)
        }
    }
}

// MARK: - Preview

#Preview("Coordinator / Bootstrapping") {
    AppCoordinatorView(
        store: Store(
            initialState: AppCoordinatorFeature.State(
                phase: .bootstrapping,
                isRestoringSession: true
            )
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = {
                try await Task.sleep(nanoseconds: 60_000_000_000)
                return nil
            }
        }
    )
}

#Preview("Coordinator / Login") {
    AppCoordinatorView(
        store: Store(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State())
            )
        ) {
            AppCoordinatorFeature()
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

#Preview("Coordinator / Onboarding") {
    AppCoordinatorView(
        store: Store(
            initialState: AppCoordinatorFeature.State(
                phase: .onboarding(OnboardingPlaceholderFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.logout = {}
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("Coordinator / Main") {
    AppCoordinatorView(
        store: Store(
            initialState: AppCoordinatorFeature.State(
                phase: .main(PlaceholderFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
        }
    )
}

#Preview("Coordinator / Main + Toast") {
    AppCoordinatorView(
        store: Store(
            initialState: AppCoordinatorFeature.State(
                phase: .main(PlaceholderFeature.State()),
                overlay: OverlayFeature.State(
                    toastMessage: "홈으로 이동했어요"
                )
            )
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
        }
    )
}

#Preview("Coordinator / Login + Toast") {
    AppCoordinatorView(
        store: Store(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State()),
                overlay: OverlayFeature.State(
                    toastMessage: "로그인에 실패했어요"
                )
            )
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.login = { _ in
                throw AuthError.loginFailed
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("Coordinator / Login + Alert") {
    AppCoordinatorView(
        store: Store(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State()),
                overlay: OverlayFeature.State(
                    alertMessage: "로그인 설정이 완료되지 않았어요."
                )
            )
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.login = { _ in
                throw AuthError.notConfigured(message: "missing-key")
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

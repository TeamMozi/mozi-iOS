import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct RootFlowView: View {
    @Bindable public var store: StoreOf<RootFlowFeature>

    public init(store: StoreOf<RootFlowFeature>) {
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
                    OnboardingFlowView(store: onboardingStore)
                }
            case .main:
                if let mainStore = store.scope(state: \.mainTab, action: \.main) {
                    MainTabView(store: mainStore)
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

#Preview("RootFlow / Bootstrapping") {
    RootFlowView(
        store: Store(
            initialState: RootFlowFeature.State(
                phase: .bootstrapping,
                isRestoringSession: true
            )
        ) {
            RootFlowFeature()
        } withDependencies: {
            $0.authClient.restoreSession = {
                try await Task.sleep(nanoseconds: 60_000_000_000)
                return nil
            }
        }
    )
}

#Preview("RootFlow / Login") {
    RootFlowView(
        store: Store(
            initialState: RootFlowFeature.State(
                phase: .login(LoginFeature.State())
            )
        ) {
            RootFlowFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.login = { _ in
                AuthSession(
                    accessToken: "preview-access",
                    refreshToken: "preview-refresh",
                    isNewUser: false,
                    profileCompleted: true,
                    userID: "preview-user"
                )
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("RootFlow / Onboarding") {
    RootFlowView(
        store: Store(
            initialState: RootFlowFeature.State(
                phase: .onboarding(OnboardingFlowFeature.State())
            )
        ) {
            RootFlowFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.logout = {}
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("RootFlow / Main") {
    RootFlowView(
        store: Store(
            initialState: RootFlowFeature.State(
                phase: .main(MainTabFeature.State())
            )
        ) {
            RootFlowFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.logout = {}
        }
    )
}

#Preview("RootFlow / Main + Toast") {
    RootFlowView(
        store: Store(
            initialState: RootFlowFeature.State(
                phase: .main(MainTabFeature.State()),
                overlay: OverlayFeature.State(
                    toastMessage: "홈으로 이동했어요"
                )
            )
        ) {
            RootFlowFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
            $0.authClient.logout = {}
        }
    )
}

#Preview("RootFlow / Login + Toast") {
    RootFlowView(
        store: Store(
            initialState: RootFlowFeature.State(
                phase: .login(LoginFeature.State()),
                overlay: OverlayFeature.State(
                    toastMessage: "로그인에 실패했어요"
                )
            )
        ) {
            RootFlowFeature()
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

#Preview("RootFlow / Login + Alert") {
    RootFlowView(
        store: Store(
            initialState: RootFlowFeature.State(
                phase: .login(LoginFeature.State()),
                overlay: OverlayFeature.State(
                    alertMessage: "로그인 설정이 완료되지 않았어요."
                )
            )
        ) {
            RootFlowFeature()
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

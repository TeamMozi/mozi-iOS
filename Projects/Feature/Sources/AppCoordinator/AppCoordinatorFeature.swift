import Domain
import Foundation
import ThirdParty

@Reducer
public struct AppCoordinatorFeature {
    @ObservableState
    public struct State: Equatable {
        public var phase: Phase = .bootstrapping
        public var isRestoringSession = false
        public var pendingDeepLink: DeepLinkRoute?
        public var overlay = OverlayFeature.State()

        public init(
            phase: Phase = .bootstrapping,
            isRestoringSession: Bool = false,
            pendingDeepLink: DeepLinkRoute? = nil,
            overlay: OverlayFeature.State = OverlayFeature.State()
        ) {
            self.phase = phase
            self.isRestoringSession = isRestoringSession
            self.pendingDeepLink = pendingDeepLink
            self.overlay = overlay
        }

        public enum Phase: Equatable {
            case bootstrapping
            case login(LoginFeature.State)
            case onboarding(OnboardingPlaceholderFeature.State)
            case main(PlaceholderFeature.State)
        }

        public var login: LoginFeature.State? {
            get {
                guard case let .login(state) = phase else { return nil }
                return state
            }
            set {
                if let newValue {
                    phase = .login(newValue)
                }
            }
        }

        public var onboarding: OnboardingPlaceholderFeature.State? {
            get {
                guard case let .onboarding(state) = phase else { return nil }
                return state
            }
            set {
                if let newValue {
                    phase = .onboarding(newValue)
                }
            }
        }

        public var mainPlaceholder: PlaceholderFeature.State? {
            get {
                guard case let .main(state) = phase else { return nil }
                return state
            }
            set {
                if let newValue {
                    phase = .main(newValue)
                }
            }
        }
    }

    public enum Action: Equatable {
        case onAppear
        case bootstrapResponse(Result<AuthSession?, AuthError>)
        case deepLinkReceived(URL)
        case routeDeepLink(DeepLinkRoute)
        case flushPendingDeepLink
        case login(LoginFeature.Action)
        case onboarding(OnboardingPlaceholderFeature.Action)
        case main(PlaceholderFeature.Action)
        case overlay(OverlayFeature.Action)
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.overlay, action: \.overlay) {
            OverlayFeature()
        }
        Reduce(core)
            .ifLet(\.login, action: \.login) {
                LoginFeature()
            }
            .ifLet(\.onboarding, action: \.onboarding) {
                OnboardingPlaceholderFeature()
            }
            .ifLet(\.mainPlaceholder, action: \.main) {
                PlaceholderFeature()
            }
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return bootstrapIfNeeded(state: &state)

        case let .bootstrapResponse(result):
            return handleBootstrapResponse(state: &state, result: result)

        case let .deepLinkReceived(url):
            guard let route = DeepLinkRouter.parse(url) else {
                return .none
            }
            return .send(.routeDeepLink(route))

        case let .routeDeepLink(route):
            return handleDeepLinkRoute(state: &state, route: route)

        case .flushPendingDeepLink:
            return flushPendingDeepLink(state: &state)

        case let .login(.delegate(.loggedIn(session))):
            applySession(&state, session: session)
            return .send(.flushPendingDeepLink)

        case let .login(.delegate(.presentToast(message))):
            return .send(.overlay(.showToast(message)))

        case let .login(.delegate(.presentAlert(message))):
            return .send(.overlay(.showAlert(message)))

        case .onboarding(.delegate(.loggedOut)):
            state.phase = .login(LoginFeature.State())
            return .none

        case .login, .onboarding, .main, .overlay:
            return .none
        }
    }

    private func bootstrapIfNeeded(state: inout State) -> Effect<Action> {
        guard case .bootstrapping = state.phase else {
            return .none
        }
        // 응답 전 중복 onAppear 가 와도 restore 는 한 번만 실행한다.
        guard state.isRestoringSession == false else {
            return .none
        }

        state.isRestoringSession = true
        return .run { [authClient] send in
            do {
                let session = try await authClient.restoreSession()
                await send(.bootstrapResponse(.success(session)))
            } catch let error as AuthError {
                await send(.bootstrapResponse(.failure(error)))
            } catch {
                await send(
                    .bootstrapResponse(
                        .failure(.unknown(message: error.localizedDescription))
                    )
                )
            }
        }
    }

    private func handleBootstrapResponse(
        state: inout State,
        result: Result<AuthSession?, AuthError>
    ) -> Effect<Action> {
        // 진행 중이던 restore 응답만 반영한다.
        guard state.isRestoringSession else {
            return .none
        }
        state.isRestoringSession = false

        switch result {
        case let .success(session):
            applySession(&state, session: session)
        case .failure:
            // restore 실패 시 안전하게 로그인 게이트로 보낸다.
            state.phase = .login(LoginFeature.State())
        }
        return .send(.flushPendingDeepLink)
    }

    private func handleDeepLinkRoute(
        state: inout State,
        route: DeepLinkRoute
    ) -> Effect<Action> {
        switch state.phase {
        case .bootstrapping, .login, .onboarding:
            state.pendingDeepLink = route
            return .none
        case .main:
            // placeholder 골격: home 딥링크는 현재 main scene 유지
            _ = route
            return .none
        }
    }

    private func flushPendingDeepLink(state: inout State) -> Effect<Action> {
        guard case .main = state.phase else {
            return .none
        }
        guard let route = state.pendingDeepLink else {
            return .none
        }
        state.pendingDeepLink = nil
        return .send(.routeDeepLink(route))
    }

    private func applySession(
        _ state: inout State,
        session: AuthSession?
    ) {
        guard let session else {
            state.phase = .login(LoginFeature.State())
            return
        }

        if session.profileCompleted {
            state.phase = .main(PlaceholderFeature.State())
        } else {
            state.phase = .onboarding(OnboardingPlaceholderFeature.State())
        }
    }
}

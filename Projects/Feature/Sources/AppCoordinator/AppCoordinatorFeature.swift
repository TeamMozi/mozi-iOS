import Foundation
import ThirdParty

@Reducer
public struct AppCoordinatorFeature {
    @ObservableState
    public struct State: Equatable {
        public var phase: Phase = .bootstrapping
        public var pendingDeepLink: DeepLinkRoute?
        public var overlay = OverlayFeature.State()

        public init(
            phase: Phase = .bootstrapping,
            pendingDeepLink: DeepLinkRoute? = nil,
            overlay: OverlayFeature.State = OverlayFeature.State()
        ) {
            self.phase = phase
            self.pendingDeepLink = pendingDeepLink
            self.overlay = overlay
        }

        public enum Phase: Equatable {
            case bootstrapping
            case main(PlaceholderFeature.State)
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
        case deepLinkReceived(URL)
        case routeDeepLink(DeepLinkRoute)
        case flushPendingDeepLink
        case main(PlaceholderFeature.Action)
        case overlay(OverlayFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.overlay, action: \.overlay) {
            OverlayFeature()
        }
        Reduce(core)
            .ifLet(\.mainPlaceholder, action: \.main) {
                PlaceholderFeature()
            }
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            guard case .bootstrapping = state.phase else {
                return .none
            }
            state.phase = .main(PlaceholderFeature.State())
            return .send(.flushPendingDeepLink)

        case let .deepLinkReceived(url):
            guard let route = DeepLinkRouter.parse(url) else {
                return .none
            }
            return .send(.routeDeepLink(route))

        case let .routeDeepLink(route):
            switch state.phase {
            case .bootstrapping:
                state.pendingDeepLink = route
                return .none
            case .main:
                // Placeholder scaffold: home deep link keeps current main scene.
                _ = route
                return .none
            }

        case .flushPendingDeepLink:
            guard let route = state.pendingDeepLink else {
                return .none
            }
            state.pendingDeepLink = nil
            return .send(.routeDeepLink(route))

        case .main, .overlay:
            return .none
        }
    }
}

import Foundation
import ThirdParty

/// 온보딩 구간의 화면 스택. 자리표시 화면이 root 이고 온보딩 네 화면은 아직 없다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct OnboardingFlowFeature {
    /// 온보딩(root) 위로 쌓이는 화면. 아직 없다
    @Reducer
    public enum Route {}

    @ObservableState
    public struct State: Equatable {
        public var onboarding: OnboardingPlaceholderFeature.State
        public var path = StackState<Route.State>()

        public init(
            onboarding: OnboardingPlaceholderFeature.State = OnboardingPlaceholderFeature.State(),
            path: StackState<Route.State> = StackState<Route.State>()
        ) {
            self.onboarding = onboarding
            self.path = path
        }
    }

    public enum Action: Equatable {
        case path(StackActionOf<Route>)
        case onboarding(OnboardingPlaceholderFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 온보딩 끝. RootFlow 가 메인으로 넘긴다
            case finished
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingPlaceholderFeature()
        }
        Reduce(core)
            .forEach(\.path, action: \.path)
            .logged(as: Self.self, children: ["onboarding"])
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onboarding(.delegate(.finished)):
            return .send(.delegate(.finished))

        case .path, .onboarding, .delegate:
            return .none
        }
    }
}

extension OnboardingFlowFeature.Route.State: Equatable {}
extension OnboardingFlowFeature.Route.Action: Equatable {}

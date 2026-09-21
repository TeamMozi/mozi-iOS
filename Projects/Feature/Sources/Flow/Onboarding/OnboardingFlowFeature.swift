import Foundation
import ThirdParty

/// 온보딩 구간의 화면 스택. 자리표시 화면이 root 이고 온보딩 네 화면은 아직 없다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct OnboardingFlowFeature {
    /// 온보딩(root) 위로 쌓이는 화면. 아직 없다
    public enum Route: Hashable {}

    @ObservableState
    public struct State: Equatable {
        public var onboarding: OnboardingPlaceholderFeature.State
        public var path: [Route]

        public init(
            onboarding: OnboardingPlaceholderFeature.State = OnboardingPlaceholderFeature.State(),
            path: [Route] = []
        ) {
            self.onboarding = onboarding
            self.path = path
        }
    }

    public enum Action: Equatable {
        case pathChanged([Route])
        case onboarding(OnboardingPlaceholderFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingPlaceholderFeature()
        }
        Reduce(core)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .pathChanged(path):
            state.path = path
            return .none

        case .onboarding:
            return .none
        }
    }
}

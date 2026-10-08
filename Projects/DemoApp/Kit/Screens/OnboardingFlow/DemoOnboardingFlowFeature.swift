import Feature
import ThirdParty

/// 온보딩 흐름 데모의 겹치는 층. 흐름이 끝나거나 로그아웃하면 처음 화면으로 되돌린다.
@Reducer
public struct DemoOnboardingFlowFeature {
    @ObservableState
    public struct State: Equatable {
        public var flow: OnboardingFlowFeature.State

        public init(flow: OnboardingFlowFeature.State = OnboardingFlowFeature.State()) {
            self.flow = flow
        }
    }

    public enum Action: Equatable {
        case flow(OnboardingFlowFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.flow, action: \.flow) {
            OnboardingFlowFeature()
        }
        Reduce { state, action in
            switch action {
            case .flow(.delegate(.finished)), .flow(.delegate(.loggedOut)):
                state.flow = OnboardingFlowFeature.State()
                return .none
            case .flow:
                return .none
            }
        }
    }
}

import Foundation
import ThirdParty

@Reducer
public struct OnboardingPlaceholderFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case finishTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 온보딩을 끝냈다. 온보딩 Flow 를 거쳐 RootFlow 가 메인으로 넘긴다
            case finished
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .finishTapped:
                return .send(.delegate(.finished))

            case .onAppear, .delegate:
                return .none
            }
        }
        .logged(as: Self.self, children: [])
    }
}

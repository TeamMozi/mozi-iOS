import Foundation
import ThirdParty

/// 숏폼 탭의 화면 스택. 자리표시 화면이 root 이고 그 위로 `Route` 화면을 쌓는다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct ShortformFlowFeature {
    /// 숏폼(root) 위로 쌓이는 화면. 견본은 세로 피드 화면이 숏폼을 채울 때 지운다
    @Reducer
    public enum Route {
        case sample(NavigationSampleFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public var placeholder: PlaceholderFeature.State
        public var path = StackState<Route.State>()

        public init(
            placeholder: PlaceholderFeature.State = PlaceholderFeature.State(title: "Shortform"),
            path: StackState<Route.State> = StackState<Route.State>()
        ) {
            self.placeholder = placeholder
            self.path = path
        }
    }

    public enum Action: Equatable {
        case path(StackActionOf<Route>)
        case placeholder(PlaceholderFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.placeholder, action: \.placeholder) {
            PlaceholderFeature()
        }
        Reduce(core)
            .forEach(\.path, action: \.path)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .path(.element(id: _, action: .sample(.delegate(.nextRequested)))):
            let number = state.path.count + 1
            state.path.append(.sample(NavigationSampleFeature.State(number: number)))
            return .none

        case .path, .placeholder:
            return .none
        }
    }
}

extension ShortformFlowFeature.Route.State: Equatable {}
extension ShortformFlowFeature.Route.Action: Equatable {}

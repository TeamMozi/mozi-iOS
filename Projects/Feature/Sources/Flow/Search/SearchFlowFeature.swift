import Foundation
import ThirdParty

/// 검색 탭의 화면 스택. 자리표시 화면이 root 이고 그 위로 쌓이는 화면은 아직 없다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct SearchFlowFeature {
    /// 검색(root) 위로 쌓이는 화면. 아직 없다
    @Reducer
    public enum Route {}

    @ObservableState
    public struct State: Equatable {
        public var placeholder: PlaceholderFeature.State
        public var path = StackState<Route.State>()

        public init(
            placeholder: PlaceholderFeature.State = PlaceholderFeature.State(title: "Search"),
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
            .logged(as: Self.self, children: ["placeholder"])
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .path, .placeholder:
            return .none
        }
    }
}

extension SearchFlowFeature.Route.State: Equatable {}
extension SearchFlowFeature.Route.Action: Equatable {}

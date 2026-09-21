import Foundation
import ThirdParty

/// 생성 탭의 화면 스택. 자리표시 화면이 root 이고 그 위로 쌓이는 화면은 아직 없다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct CreateFlowFeature {
    /// 생성(root) 위로 쌓이는 화면. 아직 없다
    public enum Route: Hashable {}

    @ObservableState
    public struct State: Equatable {
        public var placeholder: PlaceholderFeature.State
        public var path: [Route]

        public init(
            placeholder: PlaceholderFeature.State = PlaceholderFeature.State(title: "Create"),
            path: [Route] = []
        ) {
            self.placeholder = placeholder
            self.path = path
        }
    }

    public enum Action: Equatable {
        case pathChanged([Route])
        case placeholder(PlaceholderFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.placeholder, action: \.placeholder) {
            PlaceholderFeature()
        }
        Reduce(core)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .pathChanged(path):
            state.path = path
            return .none

        case .placeholder:
            return .none
        }
    }
}

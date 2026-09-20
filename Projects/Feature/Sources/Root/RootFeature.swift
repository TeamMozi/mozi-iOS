import Foundation
import ThirdParty

@Reducer
public struct RootFeature {
    @ObservableState
    public struct State: Equatable {
        public var rootFlow = RootFlowFeature.State()

        public init(rootFlow: RootFlowFeature.State = RootFlowFeature.State()) {
            self.rootFlow = rootFlow
        }
    }

    public enum Action: Equatable {
        case rootFlow(RootFlowFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.rootFlow, action: \.rootFlow) {
            RootFlowFeature()
        }
    }
}

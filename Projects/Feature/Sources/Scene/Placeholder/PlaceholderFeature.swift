import Foundation
import ThirdParty

@Reducer
public struct PlaceholderFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String

        public init(title: String) {
            self.title = title
        }
    }

    public enum Action: Equatable {
        case onAppear
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}

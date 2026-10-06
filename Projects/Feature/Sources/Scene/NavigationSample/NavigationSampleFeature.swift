import Foundation
import ThirdParty

/// 탭 안 화면 이동 견본. 제목과 「다음」만 있다. 「다음」은 delegate 로 올리고, 다음 견본은 숏폼 Flow 가 쌓는다.
///
/// 본 앱에서는 쌓지 않는다. 세로 피드 화면이 숏폼을 채울 때 데모 「탭 안 이동」과 함께 지운다
@Reducer
public struct NavigationSampleFeature {
    @ObservableState
    public struct State: Equatable {
        /// 몇 번째로 쌓인 견본인지. 1부터 센다
        public var number: Int

        public init(number: Int) {
            self.number = number
        }

        public var title: String {
            "견본 \(number)"
        }
    }

    public enum Action: Equatable {
        case nextTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 다음 견본을 원한다. 숏폼 Flow 가 path 에 하나 더 쌓는다
            case nextRequested
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .nextTapped:
                return .send(.delegate(.nextRequested))

            case .delegate:
                return .none
            }
        }
        .logged(as: Self.self, children: [])
    }
}

import Foundation
import ThirdParty

/// 마이 탭의 화면 스택. 마이페이지 자리표시 화면이 root 이고 그 위로 쌓이는 화면은 아직 없다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct MyPageFlowFeature {
    /// 마이페이지(root) 위로 쌓이는 화면. 아직 없다
    public enum Route: Hashable {}

    @ObservableState
    public struct State: Equatable {
        public var myPage: MyPagePlaceholderFeature.State
        public var path: [Route]

        public init(
            myPage: MyPagePlaceholderFeature.State = MyPagePlaceholderFeature.State(),
            path: [Route] = []
        ) {
            self.myPage = myPage
            self.path = path
        }
    }

    public enum Action: Equatable {
        case pathChanged([Route])
        case myPage(MyPagePlaceholderFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 로그아웃 성공. MainTab 을 거쳐 RootFlow 까지 올라가 로그인으로 되돌린다
            case loggedOut
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.myPage, action: \.myPage) {
            MyPagePlaceholderFeature()
        }
        Reduce(core)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .pathChanged(path):
            state.path = path
            return .none

        case .myPage(.delegate(.loggedOut)):
            return .send(.delegate(.loggedOut))

        case .myPage, .delegate:
            return .none
        }
    }
}

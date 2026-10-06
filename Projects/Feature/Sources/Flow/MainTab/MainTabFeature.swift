import Foundation
import ThirdParty

/// 탭 다섯을 쥐는 허브. 탭 사이 이동은 여기서만 한다.
@Reducer
public struct MainTabFeature {
    public enum Tab: String, Equatable, Sendable, CaseIterable {
        case shortform
        case search
        case chat
        case myPage
        case create
    }

    @ObservableState
    public struct State: Equatable {
        public var selectedTab: Tab
        public var shortform: ShortformFlowFeature.State
        public var search: SearchFlowFeature.State
        public var chat: ChatFlowFeature.State
        public var myPage: MyPageFlowFeature.State
        public var create: CreateFlowFeature.State

        public init(
            selectedTab: Tab = .shortform,
            shortform: ShortformFlowFeature.State = ShortformFlowFeature.State(),
            search: SearchFlowFeature.State = SearchFlowFeature.State(),
            chat: ChatFlowFeature.State = ChatFlowFeature.State(),
            myPage: MyPageFlowFeature.State = MyPageFlowFeature.State(),
            create: CreateFlowFeature.State = CreateFlowFeature.State()
        ) {
            self.selectedTab = selectedTab
            self.shortform = shortform
            self.search = search
            self.chat = chat
            self.myPage = myPage
            self.create = create
        }
    }

    public enum Action: Equatable {
        case tabSelected(Tab)
        /// 메인에서 받은 딥링크. RootFlow 가 넘긴다. 딥링크 종류를 더하면 여기서 처리한다
        case openDeepLink(DeepLinkRoute)
        case shortform(ShortformFlowFeature.Action)
        case search(SearchFlowFeature.Action)
        case chat(ChatFlowFeature.Action)
        case myPage(MyPageFlowFeature.Action)
        case create(CreateFlowFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 로그아웃 성공. RootFlow 까지 올라가 로그인으로 되돌린다
            case loggedOut
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.shortform, action: \.shortform) {
            ShortformFlowFeature()
        }
        Scope(state: \.search, action: \.search) {
            SearchFlowFeature()
        }
        Scope(state: \.chat, action: \.chat) {
            ChatFlowFeature()
        }
        Scope(state: \.myPage, action: \.myPage) {
            MyPageFlowFeature()
        }
        Scope(state: \.create, action: \.create) {
            CreateFlowFeature()
        }
        Reduce(core)
            .logged(as: Self.self, children: ["shortform", "search", "chat", "myPage", "create"])
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .tabSelected(tab):
            state.selectedTab = tab
            return .none

        case let .openDeepLink(route):
            switch route {
            case .home:
                // 첫 탭이 숏폼이다. 숏폼으로 돌아가 쌓인 화면을 모두 비운다
                state.selectedTab = .shortform
                state.shortform.path.removeAll()
                return .none
            }

        case .myPage(.delegate(.loggedOut)):
            return .send(.delegate(.loggedOut))

        case .shortform, .search, .chat, .myPage, .create, .delegate:
            return .none
        }
    }
}

/// 첫 화면의 흐름 일곱. 화면이나 상태를 더하는 작업은 여기에도 한 줄 더한다.
public enum DemoFlow: String, CaseIterable, Identifiable, Hashable {
    case login
    case onboarding
    case shortform
    case search
    case create
    case chat
    case myPage

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .login: "로그인"
        case .onboarding: "온보딩"
        case .shortform: "숏폼"
        case .search: "검색"
        case .create: "만들기"
        case .chat: "채팅"
        case .myPage: "마이"
        }
    }

    public var screens: [DemoScreen] {
        switch self {
        case .login: [.login]
        case .shortform: [.tabNavigation]
        case .onboarding, .search, .create, .chat, .myPage: []
        }
    }

    /// 화면이 하나라도 있어야 목록에서 열린다. 없으면 「준비 중」이다.
    public var isReady: Bool { !screens.isEmpty }

    /// 첫 화면 줄 끝 글.
    public var screenCountLabel: String { "화면 \(screens.count)" }

    /// 흐름 화면 제목 아래 글.
    public var screenCountTitle: String { "화면 \(screens.count)개" }
}

/// 흐름 안의 화면. 상태 목록은 화면마다 따로 둔다.
public enum DemoScreen: String, Hashable, Identifiable {
    case login
    case tabNavigation

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .login: "로그인"
        case .tabNavigation: "탭 안 이동"
        }
    }

    var stateTitles: [String] {
        switch self {
        case .login: LoginDemoState.allCases.map(\.title)
        case .tabNavigation: TabNavigationDemoState.allCases.map(\.title)
        }
    }

    /// 흐름 화면 줄의 보조 글. 예: 「상태 3개 · 기본, 불러오는 중, 오류 안내」
    public var stateSummary: String {
        "상태 \(stateTitles.count)개 · " + stateTitles.joined(separator: ", ")
    }

    /// 자기 NavigationStack 을 가진 Feature Flow 를 띄우는 화면이다.
    /// 데모 최상위 NavigationStack 에 쌓으면 뒤로 가기가 꼬이므로 전체 화면으로 덮어 띄운다.
    public var presentsFullScreen: Bool {
        switch self {
        case .login: false
        case .tabNavigation: true
        }
    }
}

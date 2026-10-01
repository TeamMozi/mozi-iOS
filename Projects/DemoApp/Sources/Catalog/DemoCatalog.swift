/// 첫 화면의 흐름 일곱. 화면이나 상태를 더하는 작업은 여기에도 한 줄 더한다.
enum DemoFlow: String, CaseIterable, Identifiable, Hashable {
    case login
    case onboarding
    case shortform
    case search
    case create
    case chat
    case myPage

    var id: String { rawValue }

    var title: String {
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

    var screens: [DemoScreen] {
        switch self {
        case .login: [.login]
        case .onboarding, .shortform, .search, .create, .chat, .myPage: []
        }
    }

    /// 화면이 하나라도 있어야 목록에서 열린다. 없으면 「준비 중」이다.
    var isReady: Bool { !screens.isEmpty }

    /// 첫 화면 줄 끝 글.
    var screenCountLabel: String { "화면 \(screens.count)" }

    /// 흐름 화면 제목 아래 글.
    var screenCountTitle: String { "화면 \(screens.count)개" }
}

/// 흐름 안의 화면. 상태 목록은 화면마다 따로 둔다.
enum DemoScreen: String, Hashable, Identifiable {
    case login

    var id: String { rawValue }

    var title: String {
        switch self {
        case .login: "로그인"
        }
    }

    var stateTitles: [String] {
        switch self {
        case .login: LoginDemoState.allCases.map(\.title)
        }
    }

    /// 흐름 화면 줄의 보조 글. 예: 「상태 3개 · 기본, 불러오는 중, 오류 안내」
    var stateSummary: String {
        "상태 \(stateTitles.count)개 · " + stateTitles.joined(separator: ", ")
    }
}

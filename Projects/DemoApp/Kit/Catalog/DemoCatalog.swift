/// 첫 화면의 흐름 여덟. 화면이나 상태를 더하는 작업은 여기에도 한 줄 더한다.
public enum DemoFlow: String, CaseIterable, Identifiable, Hashable {
    case login
    case onboarding
    case shortform
    case meeting
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
        case .meeting: "모임"
        case .search: "검색"
        case .create: "만들기"
        case .chat: "채팅"
        case .myPage: "마이"
        }
    }

    public var screens: [DemoScreen] {
        switch self {
        case .login: [.login]
        case .onboarding: [.profileSetting, .interestSetting, .onboardingFlow]
        case .shortform: [.tabNavigation]
        case .meeting: [.createMeeting, .meetingDetail, .meetingWidget]
        case .search, .create, .chat, .myPage: []
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
    case profileSetting
    case interestSetting
    case onboardingFlow
    case tabNavigation
    case createMeeting
    case meetingDetail
    case meetingWidget

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .login: "로그인"
        case .profileSetting: "프로필 설정"
        case .interestSetting: "카테고리 설정"
        case .onboardingFlow: "온보딩 흐름 전체"
        case .tabNavigation: "탭 안 이동"
        case .createMeeting: "모임 만들기"
        case .meetingDetail: "모임 상세"
        case .meetingWidget: "위젯 / 스냅포인트"
        }
    }

    var stateTitles: [String] {
        switch self {
        case .login: LoginDemoState.allCases.map(\.title)
        case .profileSetting: ProfileSettingDemoState.allCases.map(\.title)
        case .interestSetting: InterestSettingDemoState.allCases.map(\.title)
        case .onboardingFlow: OnboardingFlowDemoState.allCases.map(\.title)
        case .tabNavigation: TabNavigationDemoState.allCases.map(\.title)
        case .createMeeting: CreateMeetingDemoState.allCases.map(\.title)
        case .meetingDetail: MeetingDetailDemoState.allCases.map(\.title)
        case .meetingWidget: MeetingWidgetDemoState.allCases.map(\.title)
        }
    }

    /// 흐름 화면 줄의 보조 글. 예: 「상태 3개 · 기본, 불러오는 중, 오류 안내」
    public var stateSummary: String {
        "상태 \(stateTitles.count)개 · " + stateTitles.joined(separator: ", ")
    }

    /// 데모 메뉴에 「화면 모드」 를 둘지. 로그인 화면은 스스로 다크를 골라 두지 않는다.
    public var selectsAppearance: Bool {
        switch self {
        case .login: false
        case .profileSetting, .interestSetting, .onboardingFlow, .tabNavigation, .createMeeting, .meetingDetail,
             .meetingWidget: true
        }
    }

    /// 자기 NavigationStack 을 가진 Feature Flow 를 띄우는 화면이다.
    /// 데모 최상위 NavigationStack 에 쌓으면 뒤로 가기가 꼬이므로 전체 화면으로 덮어 띄운다.
    /// 온보딩 두 화면은 툴바를 그리려고 자기 NavigationStack 으로 감싼다.
    public var presentsFullScreen: Bool {
        switch self {
        case .login: false
        case .profileSetting, .interestSetting, .onboardingFlow, .tabNavigation, .createMeeting, .meetingDetail,
             .meetingWidget: true
        }
    }
}

import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 온보딩 첫 화면. 입력값을 모아 `delegate(.submitted)` 로 올린다. 서버에는 보내지 않는다.
/// 뒤로는 로그아웃이다. 로그아웃은 온보딩 Flow 가 부르고, 그동안 `screen` 을 `.loading` 으로 둔다.
@Reducer
public struct ProfileSettingFeature {
    /// 생년월일 목록을 정하는 오늘. 화면이 처음 나타날 때 정한다.
    public struct Today: Equatable, Sendable {
        public var year: Int
        public var month: Int
        public var day: Int

        public init(year: Int, month: Int, day: Int) {
            self.year = year
            self.month = month
            self.day = day
        }
    }

    /// 성별 칸의 메뉴 순서
    public static let genderOptions: [Gender] = [.male, .female]
    /// 연도 목록은 올해부터 이만큼 전까지다
    static let birthYearSpan = 100

    @ObservableState
    public struct State: Equatable {
        public var nickname: String
        public var birthYear: Int?
        public var birthMonth: Int?
        public var birthDay: Int?
        public var gender: Gender?
        public var introduction: String
        public var profileImage: ImageInput
        public var today: Today?
        /// `.loading` 은 로그아웃 중, `.actionFailed` 는 로그아웃 실패 알림이다. 온보딩 Flow 가 바꾼다
        public var screen: ScreenStatus

        public init(
            nickname: String = "",
            birthYear: Int? = nil,
            birthMonth: Int? = nil,
            birthDay: Int? = nil,
            gender: Gender? = nil,
            introduction: String = "",
            profileImage: ImageInput = .keep,
            today: Today? = nil,
            screen: ScreenStatus = .idle
        ) {
            self.nickname = nickname
            self.birthYear = birthYear
            self.birthMonth = birthMonth
            self.birthDay = birthDay
            self.gender = gender
            self.introduction = introduction
            self.profileImage = profileImage
            self.today = today
            self.screen = screen
        }

        public var isLoggingOut: Bool {
            screen == .loading
        }

        public var isStartEnabled: Bool {
            nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                && birthYear != nil
                && birthMonth != nil
                && birthDay != nil
                && gender != nil
                && isLoggingOut == false
        }

        public var yearOptions: [Int] {
            guard let today else { return [] }
            return Array(stride(from: today.year, through: today.year - ProfileSettingFeature.birthYearSpan, by: -1))
        }

        public var monthOptions: [Int] {
            guard let today else { return [] }
            return birthYear == today.year ? Array(1...today.month) : Array(1...12)
        }

        public var dayOptions: [Int] {
            guard let today else { return [] }
            let lastDay = ProfileSettingFeature.lastDay(year: birthYear, month: birthMonth)
            if birthYear == today.year, birthMonth == today.month {
                return Array(1...min(lastDay, today.day))
            }
            return Array(1...lastDay)
        }

        /// 고른 사진. 고르지 않았으면 비어 있고 화면은 모지 캐릭터를 그린다
        public var pickedPhotoData: Data? {
            guard case let .new(data) = profileImage else { return nil }
            return data
        }
    }

    public enum Action: Equatable {
        case onAppear
        case nicknameChanged(String)
        case birthYearSelected(Int)
        case birthMonthSelected(Int)
        case birthDaySelected(Int)
        case genderSelected(Gender)
        case introductionChanged(String)
        case photoPicked(Data)
        case startTapped
        case backTapped
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 입력값. `interestIDs` 는 비어 있고 카테고리 화면이 채운다
            case submitted(OnboardingDraft)
            /// 뒤로. 온보딩 Flow 가 로그아웃한다
            case backRequested
        }
    }

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce(core)
            .logged(as: Self.self, children: [])
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            setTodayIfNeeded(&state)
            return .none

        case .failureDismissed:
            state.screen = .idle
            return .none

        case .delegate:
            return .none

        case .birthYearSelected, .birthMonthSelected, .birthDaySelected:
            // 로그아웃 중에는 모든 입력을 막는다
            guard state.isLoggingOut == false else { return .none }
            selectBirthDate(&state, action: action)
            return .none

        case .nicknameChanged, .genderSelected, .introductionChanged, .photoPicked, .startTapped, .backTapped:
            guard state.isLoggingOut == false else { return .none }
            return reduceInput(&state, action: action)
        }
    }

    private func setTodayIfNeeded(_ state: inout State) {
        guard state.today == nil else { return }
        let parts = calendar.dateComponents([.year, .month, .day], from: now)
        guard let year = parts.year, let month = parts.month, let day = parts.day else { return }
        state.today = Today(year: year, month: month, day: day)
    }

    private func selectBirthDate(_ state: inout State, action: Action) {
        switch action {
        case let .birthYearSelected(year):
            guard state.yearOptions.contains(year) else { return }
            state.birthYear = year
        case let .birthMonthSelected(month):
            guard state.monthOptions.contains(month) else { return }
            state.birthMonth = month
        case let .birthDaySelected(day):
            guard state.dayOptions.contains(day) else { return }
            state.birthDay = day
        default:
            return
        }
        // 고른 년·월에 없는 달·일은 비운다
        if let month = state.birthMonth, state.monthOptions.contains(month) == false {
            state.birthMonth = nil
        }
        if let day = state.birthDay, state.dayOptions.contains(day) == false {
            state.birthDay = nil
        }
    }

    private func reduceInput(_ state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .nicknameChanged(text):
            state.nickname = String(text.prefix(UserLimit.nicknameMaxLength))
            return .none
        case let .genderSelected(gender):
            state.gender = gender
            return .none
        case let .introductionChanged(text):
            state.introduction = String(text.prefix(UserLimit.introductionMaxLength))
            return .none
        case let .photoPicked(data):
            state.profileImage = .new(data)
            return .none
        case .startTapped:
            guard let draft = makeDraft(state) else { return .none }
            return .send(.delegate(.submitted(draft)))
        case .backTapped:
            return .send(.delegate(.backRequested))
        default:
            return .none
        }
    }

    private func makeDraft(_ state: State) -> OnboardingDraft? {
        guard state.isStartEnabled,
              let year = state.birthYear,
              let month = state.birthMonth,
              let day = state.birthDay,
              let gender = state.gender,
              let birthDate = calendar.date(from: DateComponents(year: year, month: month, day: day))
        else {
            return nil
        }
        let introduction = state.introduction.trimmingCharacters(in: .whitespacesAndNewlines)
        return OnboardingDraft(
            nickname: state.nickname.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: birthDate,
            gender: gender,
            introduction: introduction.isEmpty ? nil : state.introduction,
            profileImage: state.profileImage,
            interestIDs: []
        )
    }

    /// 그 달의 마지막 날. 연도를 아직 안 골랐으면 2월은 29일까지 보인다
    static func lastDay(year: Int?, month: Int?) -> Int {
        switch month {
        case 2:
            guard let year else { return 29 }
            let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return isLeapYear ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }
}

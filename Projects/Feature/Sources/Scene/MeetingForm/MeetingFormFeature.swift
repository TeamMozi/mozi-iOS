import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 모임 만들기 시트의 첫 화면. 입력을 들고, 다음 화면과 닫기는 delegate 로 올린다.
/// 카테고리·모임 이름·날짜와 시간·장소·최대 인원이 다 차야 → 가 켜진다. 오류 문구는 없다.
/// 날짜·시간은 처음 열 때 오늘과 지금 다음 5분 칸으로 차 있고, → 를 누를 때 그 시각이 지났으면 막는다.
@Reducer
public struct MeetingFormFeature {
    public enum ScheduleField: Equatable, Sendable {
        case date
        case time
    }

    @ObservableState
    public struct State: Equatable {
        /// 지난 모임이 하나 이상이면 「이전 모임 불러오기」 줄을 보인다.
        public var hasPreviousMeetings = false
        /// 불러온 지난 모임. 🔗 줄로 표시만 하고 연결을 풀 수 없다.
        public var linkedMeeting: Meeting?
        /// 카테고리 메뉴 목록. 서버가 준 순서 그대로다. 받기가 실패하면 빈 채로 둔다.
        public var categories: [Interest] = []
        public var category: Interest?
        public var title = ""
        public var intro = ""
        public var today: DesignCalendarDay?
        public var displayedMonth: DesignCalendarMonth?
        public var startDay: DesignCalendarDay?
        public var startTime: DesignClockTime?
        public var expandedScheduleField: ScheduleField? = .date
        public var place: Place?
        public var age: MeetingAgeOption = .anyone
        public var customMinAge: Int?
        public var customMaxAge: Int?
        public var isAgeExpanded = false
        public var capacity: Int?
        public var gender: GenderRestriction = .any
        public var detail = ""
        /// 모임 정보 칸의 커서(UTF-16). 칸이 키보드를 갖지 않으면 비어 있다.
        public var detailCursor: Int?

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case task
        case previousMeetingsChecked(Bool)
        case categoriesLoaded([Interest])
        case closeTapped
        case nextTapped
        case loadPreviousTapped
        case placeTapped
        case categorySelected(Interest)
        case scheduleFieldToggled(ScheduleField)
        case monthChanged(DesignCalendarMonth)
        case daySelected(DesignCalendarDay)
        case timeSelected(DesignClockTime)
        case ageRowTapped
        case ageSelected(MeetingAgeOption)
        case customMinAgeSelected(Int)
        case customMaxAgeSelected(Int)
        case capacitySelected(Int)
        case genderSelected(GenderRestriction)
        case detailHeadingTapped(MeetingDetailHeading)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// X. 확인 없이 닫고 입력을 버린다
            case closeRequested
            case previousMeetingsRequested
            case placeRequested
            /// 다섯 칸이 다 찼고 시각이 아직 지나지 않았다
            case nextRequested
        }
    }

    @Dependency(\.meetingClient) var meetingClient
    @Dependency(\.interestClient) var interestClient
    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            Reduce(navigation)
            Reduce(schedule)
            Reduce(conditions)
            Reduce(ages)
        }
        .logged(as: Self.self, children: [])
    }

    private func navigation(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return start(&state)
        case let .previousMeetingsChecked(hasPreviousMeetings):
            state.hasPreviousMeetings = hasPreviousMeetings
            return .none
        case let .categoriesLoaded(categories):
            state.categories = categories
            return .none
        case .closeTapped:
            return .send(.delegate(.closeRequested))
        case .loadPreviousTapped:
            return .send(.delegate(.previousMeetingsRequested))
        case .placeTapped:
            return .send(.delegate(.placeRequested))
        case .nextTapped:
            guard state.isComplete else { return .none }
            guard let startAt = state.startAt(in: calendar), startAt > now else {
                // 화면에 머무는 사이 고른 시각이 지났다. 칩을 눌러 열 때처럼 다음 5분을 채워 시간 휠을 연다
                state.startTime = nextSlotTime(on: state.startDay)
                state.expandedScheduleField = .time
                return .none
            }
            return .send(.delegate(.nextRequested))
        default:
            return .none
        }
    }

    /// 화면이 열릴 때. 날짜·시간 처음 값을 채우고, 지난 모임이 있는지와 카테고리 목록을 받는다.
    private func start(_ state: inout State) -> Effect<Action> {
        let today = DesignCalendarDay(now, calendar: calendar)
        state.today = today
        // 처음 열 때만 채운다. 지난 모임을 불러와 비운 날짜·시간은 다시 채우지 않는다(정한 것 7)
        if state.linkedMeeting == nil, state.startDay == nil, state.startTime == nil,
           let start = nextStartSlot() {
            state.startDay = DesignCalendarDay(start, calendar: calendar)
            state.startTime = DesignClockTime(start, calendar: calendar)
        }
        if state.displayedMonth == nil {
            state.displayedMonth = (state.startDay ?? today).calendarMonth
        }
        let checkPrevious = Effect<Action>.run { [meetingClient] send in
            // 지난 모임이 있는지만 본다. 확인이 실패하면 줄을 숨긴 채로 둔다
            let page = try? await meetingClient.hostedMeetings(page: MeetingClient.hostedMeetingsFirstPage)
            await send(.previousMeetingsChecked(!(page?.items.isEmpty ?? true)))
        }
        guard state.categories.isEmpty else { return checkPrevious }
        return .merge(checkPrevious, .run { [interestClient] send in
            // 받기가 실패하면 메뉴를 빈 채로 둔다. 오류 창은 띄우지 않는다
            guard let categories = try? await interestClient.interests() else { return }
            await send(.categoriesLoaded(categories))
        })
    }

    private func schedule(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .scheduleFieldToggled(field):
            state.expandedScheduleField = state.expandedScheduleField == field ? nil : field
            if state.expandedScheduleField == .time, state.startTime == nil {
                state.startTime = nextSlotTime(on: state.startDay)
            }
            return .none
        case let .monthChanged(month):
            state.displayedMonth = month
            return .none
        case let .daySelected(day):
            guard day >= DesignCalendarDay(now, calendar: calendar) else { return .none }
            state.startDay = day
            state.displayedMonth = day.calendarMonth
            if let time = state.startTime, !isFuture(day: day, time: time) {
                state.startTime = nil
            }
            return .none
        case let .timeSelected(time):
            if let day = state.startDay, !isFuture(day: day, time: time) {
                return .none
            }
            state.startTime = time
            return .none
        default:
            return .none
        }
    }

    private func conditions(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .categorySelected(category):
            state.category = category
        case let .capacitySelected(capacity):
            guard MeetingLimit.capacityRange.contains(capacity) else { return .none }
            state.capacity = capacity
        case let .genderSelected(gender):
            state.gender = gender
        case let .detailHeadingTapped(heading):
            guard let inserted = heading.insert(into: state.detail, atUTF16Offset: state.detailCursor) else {
                return .none
            }
            state.detail = inserted.text
            state.detailCursor = inserted.cursor
        default:
            break
        }
        return .none
    }

    private func ages(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .ageRowTapped:
            state.isAgeExpanded.toggle()
        case let .ageSelected(option):
            state.age = option
            if option != .custom {
                state.customMinAge = nil
                state.customMaxAge = nil
            }
        case let .customMinAgeSelected(age):
            state.customMinAge = age
            if let maxAge = state.customMaxAge, maxAge < age {
                state.customMaxAge = age
            }
        case let .customMaxAgeSelected(age):
            state.customMaxAge = age
            if let minAge = state.customMinAge, minAge > age {
                state.customMinAge = age
            }
        default:
            break
        }
        return .none
    }

    /// 날짜·시간 칩의 처음 값. 지금보다 뒤인 가장 가까운 5분 단위 시각이다.
    /// 지금을 5분 칸으로 내린 시각은 늘 지금 이하라, 5분을 더하면 정확히 5분 단위인 지금(9:45:00)도 다음 칸(9:50)이 된다.
    private func nextStartSlot() -> Date? {
        let floored = DesignClockTime(now, calendar: calendar)
            .snapped(minuteInterval: MeetingFormFeatureConstant.minuteInterval)
        guard let flooredDate = floored.date(on: now, calendar: calendar) else { return nil }
        return calendar.date(byAdding: .minute, value: MeetingFormFeatureConstant.minuteInterval, to: flooredDate)
    }

    /// 시간 휠을 처음 열 때 고르는 시각. 칩의 처음 값과 같은 다음 5분이고, 고른 날에 이미 지났으면 고르지 않는다.
    private func nextSlotTime(on day: DesignCalendarDay?) -> DesignClockTime? {
        guard let start = nextStartSlot() else { return nil }
        let time = DesignClockTime(start, calendar: calendar)
        if let day, !isFuture(day: day, time: time) {
            return nil
        }
        return time
    }

    private func isFuture(day: DesignCalendarDay, time: DesignClockTime) -> Bool {
        let components = DateComponents(
            year: day.year,
            month: day.month,
            day: day.day,
            hour: time.hour,
            minute: time.minute
        )
        guard let date = calendar.date(from: components) else { return false }
        return date > now
    }
}

private enum MeetingFormFeatureConstant {
    /// 시간 휠(`DesignTimeWheel` 기본값)과 같은 분 간격.
    static let minuteInterval = 5
}

public extension MeetingFormFeature.State {
    /// → 를 켤 수 있는지. 공백뿐인 이름은 빈 이름이다.
    var isComplete: Bool {
        category != nil
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && startDay != nil
            && startTime != nil
            && place != nil
            && capacity != nil
    }

    var ageRange: AgeRange {
        age.ageRange(customMin: customMinAge, customMax: customMaxAge)
    }

    /// 고른 날과 시각을 `calendar` 의 시간대에서 한 시각으로 묶는다.
    func startAt(in calendar: Calendar) -> Date? {
        guard let startDay, let startTime else { return nil }
        return calendar.date(from: DateComponents(
            year: startDay.year,
            month: startDay.month,
            day: startDay.day,
            hour: startTime.hour,
            minute: startTime.minute
        ))
    }

    /// 만들기 입력. 다 차지 않았으면 nil 이다. 빈 소개·모임 정보는 nil 로 보낸다.
    func draft(
        in calendar: Calendar,
        poster: ImageInput,
        backgroundMusicID: String?,
        seriesID: String?
    ) -> MeetingDraft? {
        guard isComplete, let category, let place, let capacity, let startAt = startAt(in: calendar) else {
            return nil
        }
        return MeetingDraft(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            intro: intro.isEmpty ? nil : intro,
            detail: detail.isEmpty ? nil : detail,
            poster: poster,
            backgroundMusicID: backgroundMusicID,
            startAt: startAt,
            place: place,
            capacity: capacity,
            ageRange: ageRange,
            genderRestriction: gender,
            categoryID: category.id,
            seriesID: seriesID,
            joinQuestions: []
        )
    }

    /// 지난 모임을 불러와 채운다. 날짜와 시간만 비운다.
    mutating func load(from meeting: Meeting) {
        linkedMeeting = meeting
        category = meeting.category
        title = meeting.title
        intro = meeting.intro ?? ""
        detail = meeting.detail ?? ""
        detailCursor = nil
        place = meeting.place
        capacity = meeting.capacity
        gender = meeting.genderRestriction
        age = MeetingAgeOption(range: meeting.ageRange)
        customMinAge = age == .custom ? meeting.ageRange.minAge : nil
        customMaxAge = age == .custom ? meeting.ageRange.maxAge : nil
        startDay = nil
        startTime = nil
        expandedScheduleField = .date
    }
}

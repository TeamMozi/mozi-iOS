import Domain
import Feature
import Foundation
import SharedDesignSystem
import ThirdParty

/// 「만들기」 데모 상태 여덟. 상태마다 그 일이 일어나는 화면에서, 필요한 입력을 채운 채로 시트를 띄운다.
public enum CreateMeetingDemoState: String, CaseIterable, Hashable, Sendable {
    case firstCreate
    case filledForm
    case previousMeeting
    case previousPoster
    case createFailed
    case seriesOnlyFailed
    case placeEmpty
    case created

    /// 상태 시트의 줄 이름. 무엇을 눌러야 그 일이 보이는지 적는다.
    public var title: String {
        switch self {
        case .firstCreate: "빈 화면에서 처음 만들기"
        case .filledForm: "입력 다 채운 모임 만들기"
        case .previousMeeting: "지난 모임 불러오기"
        case .previousPoster: "지난 포스터 이어 쓰기"
        case .createFailed: "포스터에서 → 누르면 만들기 실패"
        case .seriesOnlyFailed: "시리즈 정보에서 → 누르면 연결만 실패"
        case .placeEmpty: "장소 검색 결과 없음"
        case .created: "만든 뒤"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        switch self {
        case .firstCreate: "처음"
        case .filledForm: "채움"
        case .previousMeeting: "불러오기"
        case .previousPoster: "포스터"
        case .createFailed: "실패"
        case .seriesOnlyFailed: "연결 실패"
        case .placeEmpty: "0건"
        case .created: "만든 뒤"
        }
    }

    /// 이 상태로 시작하는 데모 층 상태. 날짜와 시간은 `now` 다음 날 19:00 으로 채워 → 가 막히지 않게 한다.
    /// 「만든 뒤」 는 시트를 닫고 올라온 모임 한 줄을 보인 채로 시작한다.
    public func initialState(
        posterURL: URL?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> DemoCreateMeetingFeature.State {
        let flow: CreateMeetingFlowFeature.State
        switch self {
        case .created:
            return DemoCreateMeetingFeature.State(
                flow: nil,
                createdMeetingTitle: CreateMeetingDemoData.createdMeetingTitle
            )
        case .firstCreate:
            flow = CreateMeetingFlowFeature.State()
        case .filledForm:
            flow = CreateMeetingFlowFeature.State(form: Self.filledForm(now: now, calendar: calendar))
        case .previousMeeting:
            flow = CreateMeetingFlowFeature.State(path: Self.path(.previousMeeting(PreviousMeetingFeature.State())))
        case .previousPoster:
            let meeting = CreateMeetingDemoData.unboundMeeting(posterURL: posterURL)
            let selection = PosterSelection(image: posterURL.map(PosterImage.previous) ?? .empty)
            flow = CreateMeetingFlowFeature.State(
                form: Self.loadedForm(from: meeting, now: now, calendar: calendar),
                path: Self.path(.poster(PosterFeature.State(selection: selection))),
                poster: selection
            )
        case .createFailed:
            flow = CreateMeetingFlowFeature.State(
                form: Self.filledForm(now: now, calendar: calendar),
                path: Self.path(.poster(PosterFeature.State()))
            )
        case .seriesOnlyFailed:
            let meeting = CreateMeetingDemoData.unboundMeeting(posterURL: nil)
            flow = CreateMeetingFlowFeature.State(
                form: Self.loadedForm(from: meeting, now: now, calendar: calendar),
                path: Self.path(
                    .poster(PosterFeature.State()),
                    .seriesInfo(SeriesInfoFeature.State(title: CreateMeetingDemoData.seriesTitle))
                )
            )
        case .placeEmpty:
            flow = CreateMeetingFlowFeature.State(path: Self.path(.placeSearch(PlaceSearchFeature.State())))
        }
        return DemoCreateMeetingFeature.State(flow: flow)
    }

    /// 입력 위로 쌓인 화면. 마지막이 맨 위다.
    private static func path(
        _ routes: CreateMeetingFlowFeature.Route.State...
    ) -> StackState<CreateMeetingFlowFeature.Route.State> {
        StackState(routes)
    }

    /// 필수 다섯 칸(카테고리·이름·날짜와 시간·장소·최대 인원)을 채운 입력.
    private static func filledForm(now: Date, calendar: Calendar) -> MeetingFormFeature.State {
        var form = MeetingFormFeature.State()
        form.category = CreateMeetingDemoData.category
        form.title = CreateMeetingDemoData.filledTitle
        form.place = CreateMeetingDemoData.place
        form.capacity = CreateMeetingDemoData.capacity
        fillSchedule(&form, now: now, calendar: calendar)
        return form
    }

    /// 지난 모임을 불러와 채운 입력. 불러오기는 날짜와 시간을 비우므로 다시 채운다.
    private static func loadedForm(from meeting: Meeting, now: Date, calendar: Calendar) -> MeetingFormFeature.State {
        var form = MeetingFormFeature.State()
        form.load(from: meeting)
        fillSchedule(&form, now: now, calendar: calendar)
        return form
    }

    /// 다음 날 19:00. 화면의 `.task` 는 이미 찬 날짜·시간을 덮어쓰지 않는다.
    private static func fillSchedule(_ form: inout MeetingFormFeature.State, now: Date, calendar: Calendar) {
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return }
        let day = DesignCalendarDay(tomorrow, calendar: calendar)
        form.startDay = day
        form.startTime = DesignClockTime(hour: 19, minute: 0)
        form.displayedMonth = day.calendarMonth
        form.expandedScheduleField = nil
    }
}

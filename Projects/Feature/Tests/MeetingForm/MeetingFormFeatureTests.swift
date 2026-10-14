import Domain
@testable import Feature
import SharedDesignSystem
import ThirdParty
import XCTest

@MainActor
final class MeetingFormFeatureTests: XCTestCase {
    private let today = DesignCalendarDay(year: 2026, month: 7, day: 16)

    func test_지난_모임이_하나_이상이면_이전_모임_불러오기_줄을_보인다() async {
        let requested = LockIsolated<[PageRequest]>([])
        let store = makeStore {
            $0.meetingClient.hostedMeetings = { request in
                requested.withValue { $0.append(request) }
                return Page(items: [CreateMeetingFixtures.meeting()], next: nil)
            }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startTime = DesignClockTime(hour: 9, minute: 45)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(true)) {
            $0.hasPreviousMeetings = true
        }
        XCTAssertEqual(requested.value, [MeetingClient.hostedMeetingsFirstPage])
    }

    func test_지난_모임이_없으면_이전_모임_불러오기_줄을_숨긴다() async {
        let store = makeStore {
            $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startTime = DesignClockTime(hour: 9, minute: 45)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(false))
    }

    func test_지난_모임_확인이_실패하면_줄을_숨긴_채로_둔다() async {
        let store = makeStore {
            $0.meetingClient.hostedMeetings = { _ in throw MeetingError.network }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startTime = DesignClockTime(hour: 9, minute: 45)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(false))
    }

    func test_화면을_처음_열면_날짜는_오늘_시간은_지금보다_뒤인_가장_가까운_5분_단위로_채운다() async {
        // 지금 2026-07-16 09:41 KST
        let store = makeStore { $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) } }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startTime = DesignClockTime(hour: 9, minute: 45)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(false))
    }

    func test_지금이_정확히_5분_단위면_그_시각은_지금보다_뒤가_아니므로_다음_5분으로_채운다() async {
        // 2026-07-16 09:45:00 KST
        let store = makeStore {
            $0.date.now = CreateMeetingFixtures.now.addingTimeInterval(4 * 60)
            $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startTime = DesignClockTime(hour: 9, minute: 50)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(false))
    }

    func test_23시_55분_이후에_처음_열면_날짜는_다음_날_시간은_0시로_채운다() async {
        // 2026-07-16 23:57 KST
        let store = makeStore {
            $0.date.now = CreateMeetingFixtures.now.addingTimeInterval((14 * 60 + 16) * 60)
            $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 17)
            $0.startTime = DesignClockTime(hour: 0, minute: 0)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(false))
    }

    func test_이미_고른_날짜와_시간이_있으면_화면을_다시_열어도_처음_값으로_바꾸지_않는다() async {
        var state = MeetingFormFeature.State()
        state.startDay = DesignCalendarDay(year: 2026, month: 8, day: 25)
        state.startTime = DesignClockTime(hour: 19, minute: 0)
        let store = makeStore(initialState: state) {
            $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 8)
        }
        await store.receive(.previousMeetingsChecked(false))
    }

    func test_다섯_칸이_다_차면_다음을_누를_때_다음_화면을_올린다() async {
        let store = makeStore(initialState: completeState())

        await store.send(.nextTapped)
        await store.receive(.delegate(.nextRequested))
    }

    func test_최대_인원이_비어_있으면_다음을_눌러도_아무_일도_없다() async {
        var state = completeState()
        state.capacity = nil
        let store = makeStore(initialState: state)

        await store.send(.nextTapped)
    }

    func test_모임_이름이_공백뿐이면_다_찬_것으로_보지_않는다() {
        var state = completeState()
        state.title = "   "

        XCTAssertFalse(state.isComplete)
    }

    func test_지난_날짜를_고르면_무시한다() async {
        let store = makeStore()

        await store.send(.daySelected(DesignCalendarDay(year: 2026, month: 7, day: 15)))
    }

    func test_오늘_지난_시각을_고르면_무시한다() async {
        var state = MeetingFormFeature.State()
        state.startDay = today
        let store = makeStore(initialState: state)

        await store.send(.timeSelected(DesignClockTime(hour: 9, minute: 0)))
    }

    func test_오늘을_고르면_이미_고른_지난_시각을_비운다() async {
        var state = MeetingFormFeature.State()
        state.startTime = DesignClockTime(hour: 9, minute: 0)
        let store = makeStore(initialState: state)

        await store.send(.daySelected(today)) {
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
            $0.startTime = nil
        }
    }

    func test_다음을_누를_때_고른_시각이_지났으면_다음_5분을_채우고_시간_휠을_연다() async {
        var state = completeState()
        state.startDay = today
        state.startTime = DesignClockTime(hour: 9, minute: 0)
        let store = makeStore(initialState: state)

        await store.send(.nextTapped) {
            $0.startTime = DesignClockTime(hour: 9, minute: 45)
            $0.expandedScheduleField = .time
        }
    }

    func test_시간_휠을_처음_열면_다음_5분을_고른다() async {
        let store = makeStore()

        await store.send(.scheduleFieldToggled(.time)) {
            $0.expandedScheduleField = .time
            $0.startTime = DesignClockTime(hour: 9, minute: 45)
        }
    }

    func test_지난_모임을_불러오면_날짜와_시간만_비우고_나머지를_채운다() {
        let meeting = CreateMeetingFixtures.meeting()
        var state = completeState()
        state.expandedScheduleField = nil

        state.load(from: meeting)

        XCTAssertEqual(state.linkedMeeting, meeting)
        XCTAssertEqual(state.category, Interest(id: "food", name: "푸드/드링크"))
        XCTAssertEqual(state.title, "홀사이즈 케이크 먹는 모임")
        XCTAssertEqual(state.intro, "서울권 카페에서 홀사이즈 케이크 먹어요")
        XCTAssertEqual(state.detail, "✱ 준비물\n케이크를 좋아하는 마음")
        XCTAssertEqual(state.place, CreateMeetingFixtures.place)
        XCTAssertEqual(state.capacity, 14)
        XCTAssertEqual(state.gender, .female)
        XCTAssertEqual(state.age, .twenties)
        XCTAssertNil(state.startDay)
        XCTAssertNil(state.startTime)
        XCTAssertEqual(state.expandedScheduleField, .date)
    }

    func test_모임_정보_칩을_누르면_커서_자리에_머리말_한_줄을_넣는다() async {
        var state = MeetingFormFeature.State()
        state.detail = "가나\n다라"
        state.detailCursor = 3
        let store = makeStore(initialState: state)

        await store.send(.detailHeadingTapped(.fee)) {
            $0.detail = "가나\n✱ 참가비\n다라"
            $0.detailCursor = 9
        }
    }

    func test_모임_정보가_500자를_넘게_되면_머리말을_넣지_않는다() async {
        var state = MeetingFormFeature.State()
        state.detail = String(repeating: "가", count: 495)
        let store = makeStore(initialState: state)

        await store.send(.detailHeadingTapped(.fee))
    }

    func test_최대_인원은_2명부터_60명까지만_고른다() async {
        let store = makeStore()

        await store.send(.capacitySelected(61))
        await store.send(.capacitySelected(2)) {
            $0.capacity = 2
        }
    }

    func test_직접_입력_최소_나이가_최대보다_크면_최대를_맞춘다() async {
        var state = MeetingFormFeature.State()
        state.age = .custom
        state.customMaxAge = 25
        let store = makeStore(initialState: state)

        await store.send(.customMinAgeSelected(30)) {
            $0.customMinAge = 30
            $0.customMaxAge = 30
        }
    }

    func test_닫기를_누르면_닫기를_올린다() async {
        let store = makeStore()

        await store.send(.closeTapped)
        await store.receive(.delegate(.closeRequested))
    }

    func test_다_찬_입력은_한국_시간으로_묶은_만들기_입력이_된다() {
        let draft = completeState().draft(
            in: CreateMeetingFixtures.calendar,
            poster: .keep,
            backgroundMusicID: nil,
            seriesID: "series-1"
        )

        // 2026-08-25 19:00 KST
        XCTAssertEqual(draft?.startAt, Date(timeIntervalSince1970: 1_787_652_000))
        XCTAssertEqual(draft?.title, "홀사이즈 케이크 먹는 모임")
        XCTAssertEqual(draft?.categoryID, "food")
        XCTAssertEqual(draft?.capacity, 14)
        XCTAssertEqual(draft?.ageRange, AgeRange(minAge: nil, maxAge: nil))
        XCTAssertEqual(draft?.seriesID, "series-1")
        XCTAssertNil(draft?.intro)
        XCTAssertNil(draft?.detail)
    }

    private func completeState() -> MeetingFormFeature.State {
        var state = MeetingFormFeature.State()
        state.category = Interest(id: "food", name: "푸드/드링크")
        state.title = "홀사이즈 케이크 먹는 모임"
        state.startDay = DesignCalendarDay(year: 2026, month: 8, day: 25)
        state.startTime = DesignClockTime(hour: 19, minute: 0)
        state.place = CreateMeetingFixtures.place
        state.capacity = 14
        return state
    }

    private func makeStore(
        initialState: MeetingFormFeature.State = MeetingFormFeature.State(),
        dependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStoreOf<MeetingFormFeature> {
        TestStore(initialState: initialState) {
            MeetingFormFeature()
        } withDependencies: {
            $0.date.now = CreateMeetingFixtures.now
            $0.calendar = CreateMeetingFixtures.calendar
            // 카테고리 받기는 따로 본다. 나머지 테스트는 받기가 실패해 아무것도 보내지 않는다
            $0.interestClient.interests = { throw InterestError.network }
            dependencies(&$0)
        }
    }
}

extension MeetingFormFeatureTests {
    func test_지난_모임을_불러온_뒤_화면을_다시_열어도_날짜와_시간을_채우지_않는다() async {
        var state = MeetingFormFeature.State()
        state.load(from: CreateMeetingFixtures.meeting())
        let store = makeStore(initialState: state) {
            $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(false))
        XCTAssertNil(store.state.startDay)
        XCTAssertNil(store.state.startTime)
    }

    func test_화면을_열면_카테고리_목록을_받아_서버_순서대로_둔다() async {
        let interests = [Interest(id: "art", name: "문화/예술"), Interest(id: "food", name: "푸드/드링크")]
        let store = makeStore {
            $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) }
            $0.interestClient.interests = { interests }
        }
        // 지난 모임 확인과 카테고리 받기는 같이 돌아 도착 순서가 정해지지 않는다. 카테고리만 본다
        store.exhaustivity = .off

        await store.send(.task)
        await store.receive(.categoriesLoaded(interests)) {
            $0.categories = interests
        }
    }

    func test_카테고리를_이미_받았으면_다시_열어도_받지_않는다() async {
        var state = MeetingFormFeature.State()
        state.categories = [Interest(id: "art", name: "문화/예술")]
        let store = makeStore(initialState: state) {
            $0.meetingClient.hostedMeetings = { _ in Page(items: [], next: nil) }
            $0.interestClient.interests = {
                XCTFail("이미 받은 목록이 있으면 다시 받지 않는다")
                return []
            }
        }

        await store.send(.task) {
            $0.today = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startDay = DesignCalendarDay(year: 2026, month: 7, day: 16)
            $0.startTime = DesignClockTime(hour: 9, minute: 45)
            $0.displayedMonth = DesignCalendarMonth(year: 2026, month: 7)
        }
        await store.receive(.previousMeetingsChecked(false))
    }
}

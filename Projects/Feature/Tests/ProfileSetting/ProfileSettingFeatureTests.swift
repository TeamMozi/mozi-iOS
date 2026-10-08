import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

@MainActor
final class ProfileSettingFeatureTests: XCTestCase {
    private typealias State = ProfileSettingFeature.State
    private typealias Today = ProfileSettingFeature.Today

    private let today = ProfileSettingFeature.Today(year: 2026, month: 10, day: 7)

    func test_처음_나타나면_오늘_날짜를_정한다() async {
        let store = makeStore(State())

        await store.send(.onAppear) {
            $0.today = Today(year: 2026, month: 10, day: 7)
        }
    }

    func test_오늘이_정해지기_전에는_날짜_목록이_비어있다() {
        let state = State()
        XCTAssertTrue(state.yearOptions.isEmpty)
        XCTAssertTrue(state.monthOptions.isEmpty)
        XCTAssertTrue(state.dayOptions.isEmpty)
    }

    func test_연도는_올해부터_100년_전까지_내림차순이다() {
        let years = State(today: today).yearOptions
        XCTAssertEqual(years.count, 101)
        XCTAssertEqual(years.first, 2026)
        XCTAssertEqual(years.last, 1926)
        XCTAssertEqual(years, years.sorted(by: >))
    }

    func test_올해를_고르면_이번_달_뒤의_달은_없다() {
        XCTAssertEqual(State(birthYear: 2026, today: today).monthOptions, Array(1...10))
        XCTAssertEqual(State(birthYear: 2025, today: today).monthOptions, Array(1...12))
    }

    func test_올해_이번_달이면_오늘_뒤의_날은_없다() {
        XCTAssertEqual(State(birthYear: 2026, birthMonth: 10, today: today).dayOptions, Array(1...7))
        XCTAssertEqual(State(birthYear: 2026, birthMonth: 9, today: today).dayOptions, Array(1...30))
    }

    func test_일_목록은_고른_년월의_날수다() {
        XCTAssertEqual(State(birthYear: 2000, birthMonth: 2, today: today).dayOptions.count, 29)
        XCTAssertEqual(State(birthYear: 2001, birthMonth: 2, today: today).dayOptions.count, 28)
        XCTAssertEqual(State(birthYear: 2001, birthMonth: 4, today: today).dayOptions.count, 30)
        XCTAssertEqual(State(birthYear: 2001, birthMonth: 1, today: today).dayOptions.count, 31)
        XCTAssertEqual(State(birthMonth: 2, today: today).dayOptions.count, 29)
        XCTAssertEqual(State(today: today).dayOptions.count, 31)
    }

    func test_고른_달에_없는_일은_비운다() async {
        let store = makeStore(State(birthYear: 2001, birthMonth: 1, birthDay: 31, today: today))

        await store.send(.birthMonthSelected(2)) {
            $0.birthMonth = 2
            $0.birthDay = nil
        }
    }

    func test_윤년_2월_29일에서_평년으로_바꾸면_일을_비운다() async {
        let store = makeStore(State(birthYear: 2000, birthMonth: 2, birthDay: 29, today: today))

        await store.send(.birthYearSelected(2001)) {
            $0.birthYear = 2001
            $0.birthDay = nil
        }
    }

    func test_올해로_바꾸면_이번_달_뒤의_달을_비운다() async {
        let store = makeStore(State(birthYear: 2000, birthMonth: 12, birthDay: 25, today: today))

        await store.send(.birthYearSelected(2026)) {
            $0.birthYear = 2026
            $0.birthMonth = nil
        }
    }

    func test_목록에_없는_날짜는_고르지_않는다() async {
        let store = makeStore(State(birthYear: 2026, birthMonth: 10, today: today))

        await store.send(.birthYearSelected(2027))
        await store.send(.birthYearSelected(1925))
        await store.send(.birthMonthSelected(11))
        await store.send(.birthDaySelected(8))
    }

    func test_이름은_10자에서_자른다() async {
        let store = makeStore(State(today: today))

        await store.send(.nicknameChanged("가나다라마바사아자차카")) {
            $0.nickname = "가나다라마바사아자차"
        }
    }

    func test_소개는_50자에서_자른다() async {
        let store = makeStore(State(today: today))

        await store.send(.introductionChanged(String(repeating: "가", count: 51))) {
            $0.introduction = String(repeating: "가", count: 50)
        }
    }

    func test_이름_생년월일_성별이_모두_차면_시작하기가_켜진다() {
        XCTAssertTrue(filled().isStartEnabled)
    }

    func test_이름이_비었거나_공백뿐이면_시작하기가_꺼진다() {
        XCTAssertFalse(filled(nickname: "").isStartEnabled)
        XCTAssertFalse(filled(nickname: "   ").isStartEnabled)
    }

    func test_생년월일이나_성별이_비면_시작하기가_꺼진다() {
        var noYear = filled()
        noYear.birthYear = nil
        var noMonth = filled()
        noMonth.birthMonth = nil
        var noDay = filled()
        noDay.birthDay = nil
        var noGender = filled()
        noGender.gender = nil

        for state in [noYear, noMonth, noDay, noGender] {
            XCTAssertFalse(state.isStartEnabled)
        }
    }

    func test_시작하기를_누르면_입력값을_delegate로_올린다() async {
        let store = makeStore(filled(nickname: " 수연 ", introduction: "   "))

        await store.send(.startTapped)
        await store.receive(
            .delegate(
                .submitted(
                    OnboardingDraft(
                        nickname: "수연",
                        birthDate: Self.date(2000, 2, 29),
                        gender: .female,
                        introduction: nil,
                        profileImage: .keep,
                        interestIDs: []
                    )
                )
            )
        )
    }

    func test_사진을_고르면_올리는_초안에_새_사진이_담긴다() async {
        let store = makeStore(filled(introduction: "영화 좋아해요"))
        let photo = Data([1, 2, 3])

        await store.send(.photoPicked(photo)) {
            $0.profileImage = .new(photo)
        }
        XCTAssertEqual(store.state.pickedPhotoData, photo)
        await store.send(.startTapped)
        await store.receive(
            .delegate(
                .submitted(
                    OnboardingDraft(
                        nickname: "수연",
                        birthDate: Self.date(2000, 2, 29),
                        gender: .female,
                        introduction: "영화 좋아해요",
                        profileImage: .new(photo),
                        interestIDs: []
                    )
                )
            )
        )
    }

    func test_시작하기가_꺼져_있으면_눌러도_올리지_않는다() async {
        let store = makeStore(State(today: today))

        await store.send(.startTapped)
    }

    func test_성별을_고르면_담긴다() async {
        let store = makeStore(State(today: today))

        await store.send(.genderSelected(.male)) {
            $0.gender = .male
        }
        XCTAssertEqual(ProfileSettingFeature.genderOptions, [.male, .female])
    }

    func test_뒤로를_누르면_delegate로_올린다() async {
        let store = makeStore(filled())

        await store.send(.backTapped)
        await store.receive(.delegate(.backRequested))
    }

    func test_로그아웃_중에는_입력을_무시한다() async {
        let store = makeStore(filled(isLoggingOut: true))

        XCTAssertTrue(store.state.isLoggingOut)
        XCTAssertFalse(store.state.isStartEnabled)
        await store.send(.nicknameChanged("다른이름"))
        await store.send(.birthYearSelected(1999))
        await store.send(.birthMonthSelected(3))
        await store.send(.birthDaySelected(1))
        await store.send(.genderSelected(.male))
        await store.send(.introductionChanged("소개"))
        await store.send(.photoPicked(Data([9])))
        await store.send(.startTapped)
        await store.send(.backTapped)
    }

    func test_로그아웃_실패_알림을_닫으면_idle로_돌아온다() async {
        let store = makeStore(State(screen: .actionFailed(message: "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요.")))

        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
    }

    // MARK: - 도우미

    private func makeStore(_ state: State) -> TestStoreOf<ProfileSettingFeature> {
        TestStore(initialState: state) {
            ProfileSettingFeature()
        } withDependencies: {
            $0.date.now = Self.date(2026, 10, 7, hour: 12)
            $0.calendar = Self.utcCalendar
        }
    }

    private func filled(nickname: String = "수연", introduction: String = "", isLoggingOut: Bool = false) -> State {
        State(
            nickname: nickname,
            birthYear: 2000,
            birthMonth: 2,
            birthDay: 29,
            gender: .female,
            introduction: introduction,
            today: today,
            screen: isLoggingOut ? .loading : .idle
        )
    }

    private static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        utcCalendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour)) ?? .distantPast
    }
}

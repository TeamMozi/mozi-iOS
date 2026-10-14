import Domain
@testable import Feature
import SharedDesignSystem
import ThirdParty
import XCTest

@MainActor
final class CreateMeetingFlowFeatureTests: XCTestCase {
    private let created = CreateMeetingFixtures.meeting(id: "created-1")

    func test_지난_모임을_고르면_포스터와_배경음악을_이어_쓰고_불러오기_화면을_닫는다() async {
        let posterURL = URL(filePath: "/poster.jpg")
        let music = BackgroundMusic(
            id: "music-1",
            title: "키즈나 뮤직",
            albumImageURL: nil,
            durationSeconds: 99,
            useCount: 110
        )
        var meeting = CreateMeetingFixtures.meeting(id: "previous-1", posterURL: posterURL)
        meeting.backgroundMusic = music
        var loadedForm = MeetingFormFeature.State()
        loadedForm.load(from: meeting)
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                path: StackState([.previousMeeting(PreviousMeetingFeature.State())])
            )
        ) {
            CreateMeetingFlowFeature()
        }

        await store.send(.path(.element(id: 0, action: .previousMeeting(.delegate(.meetingChosen(meeting)))))) {
            $0.form = loadedForm
            $0.poster = PosterSelection(image: .previous(posterURL), music: music)
            $0.path = StackState()
        }
    }

    func test_장소를_고르면_입력에_넣고_장소_화면을_닫는다() async {
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(path: StackState([.placeSearch(PlaceSearchFeature.State())]))
        ) {
            CreateMeetingFlowFeature()
        }

        let chosen = PlaceSearchFeature.Action.delegate(.placeChosen(CreateMeetingFixtures.place))
        await store.send(.path(.element(id: 0, action: .placeSearch(chosen)))) {
            $0.form.place = CreateMeetingFixtures.place
            $0.path = StackState()
        }
    }

    func test_입력에서_다음을_올리면_들고_있던_포스터로_포스터_화면을_쌓는다() async {
        let selection = PosterSelection(image: .previous(URL(filePath: "/poster.jpg")))
        let store = TestStore(initialState: CreateMeetingFlowFeature.State(poster: selection)) {
            CreateMeetingFlowFeature()
        }

        await store.send(.form(.delegate(.nextRequested))) {
            $0.path.append(.poster(PosterFeature.State(selection: selection)))
        }
    }

    func test_포스터에서_고르면_흐름이_고른_것을_들고_있는다() async {
        let selection = PosterSelection(image: .picked(id: "photo-1", data: Data([7])))
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(path: StackState([.poster(PosterFeature.State())]))
        ) {
            CreateMeetingFlowFeature()
        }

        await store.send(.path(.element(id: 0, action: .poster(.delegate(.selectionChanged(selection)))))) {
            $0.poster = selection
        }
    }

    func test_시리즈에_묶이지_않은_지난_모임이면_포스터_다음에_시리즈_정보를_쌓는다() async {
        let linked = CreateMeetingFixtures.meeting(id: "previous-1")
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                form: completeForm(linked: linked),
                path: StackState([.poster(PosterFeature.State())])
            )
        ) {
            CreateMeetingFlowFeature()
        }

        await store.send(.path(.element(id: 0, action: .poster(.delegate(.nextRequested))))) {
            $0.path.append(.seriesInfo(SeriesInfoFeature.State()))
        }
    }

    func test_시리즈_정보를_넣고_다음을_누르면_앵콜로_만들고_만든_모임을_올린다() async {
        let linked = CreateMeetingFixtures.meeting(id: "previous-1")
        let series = CreateMeetingFixtures.series()
        let received = LockIsolated<EncoreDraft?>(nil)
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                form: completeForm(linked: linked),
                path: StackState([
                    .poster(PosterFeature.State()),
                    .seriesInfo(SeriesInfoFeature.State(title: "케이크 시리즈")),
                ])
            )
        ) {
            CreateMeetingFlowFeature()
        } withDependencies: { [created] in
            $0.calendar = CreateMeetingFixtures.calendar
            $0.meetingClient.createEncore = { draft in
                received.setValue(draft)
                return .created(created, series)
            }
        }

        let next = SeriesInfoFeature.Action.delegate(.nextRequested(title: "케이크 시리즈", intro: nil))
        await store.send(.path(.element(id: 1, action: .seriesInfo(next)))) {
            $0.submittingID = 1
            $0.path[id: 1, case: \.seriesInfo]?.isSubmitting = true
        }
        await store.receive(.encoreResponse(.success(.created(created, series)))) {
            $0.submittingID = nil
        }
        await store.receive(.delegate(.created(created)))
        XCTAssertEqual(received.value?.previousMeetingID, "previous-1")
        XCTAssertEqual(received.value?.seriesTitle, "케이크 시리즈")
        XCTAssertNil(received.value?.seriesIntro)
        XCTAssertEqual(received.value?.meeting.title, "홀사이즈 케이크 먹는 모임")
        XCTAssertEqual(received.value?.meeting.poster, .keep)
    }

    func test_시리즈에_묶인_지난_모임이면_시리즈_정보_없이_그_시리즈_칸을_채워_만든다() async {
        let linked = CreateMeetingFixtures.meeting(
            id: "previous-1",
            episode: SeriesEpisode(seriesID: "series-1", number: 2)
        )
        let received = LockIsolated<MeetingDraft?>(nil)
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                form: completeForm(linked: linked),
                path: StackState([.poster(PosterFeature.State())]),
                poster: PosterSelection(image: .previous(URL(filePath: "/poster.jpg")))
            )
        ) {
            CreateMeetingFlowFeature()
        } withDependencies: { [created] in
            $0.calendar = CreateMeetingFixtures.calendar
            $0.meetingClient.create = { draft in
                received.setValue(draft)
                return created
            }
        }

        await store.send(.path(.element(id: 0, action: .poster(.delegate(.nextRequested))))) {
            $0.submittingID = 0
            $0.path[id: 0, case: \.poster]?.isSubmitting = true
        }
        await store.receive(.createResponse(.success(created))) {
            $0.submittingID = nil
        }
        await store.receive(.delegate(.created(created)))
        XCTAssertEqual(received.value?.seriesID, "series-1")
        XCTAssertEqual(received.value?.poster, .reuse(URL(filePath: "/poster.jpg")))
    }

    func test_만들기_요청_중에는_다음을_다시_눌러도_요청을_한_번만_보낸다() async {
        let clock = TestClock()
        let calls = LockIsolated(0)
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                form: completeForm(linked: nil),
                path: StackState([.poster(PosterFeature.State())])
            )
        ) {
            CreateMeetingFlowFeature()
        } withDependencies: { [created] in
            $0.calendar = CreateMeetingFixtures.calendar
            $0.meetingClient.create = { _ in
                calls.withValue { $0 += 1 }
                try await clock.sleep(for: .seconds(1))
                return created
            }
        }

        await store.send(.path(.element(id: 0, action: .poster(.nextTapped))))
        await store.receive(.path(.element(id: 0, action: .poster(.delegate(.nextRequested))))) {
            $0.submittingID = 0
            $0.path[id: 0, case: \.poster]?.isSubmitting = true
        }
        // 요청 중이라 포스터 화면이 다시 올리지 않는다
        await store.send(.path(.element(id: 0, action: .poster(.nextTapped))))
        await clock.advance(by: .seconds(1))
        await store.receive(.createResponse(.success(created))) {
            $0.submittingID = nil
        }
        await store.receive(.delegate(.created(created)))
        XCTAssertEqual(calls.value, 1)
    }

    func test_만들기가_실패하면_시트에_남고_만들기_문구로_오류_창을_띄운다() async {
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                form: completeForm(linked: nil),
                path: StackState([.poster(PosterFeature.State())])
            )
        ) {
            CreateMeetingFlowFeature()
        } withDependencies: {
            $0.calendar = CreateMeetingFixtures.calendar
            $0.meetingClient.create = { _ in throw MeetingError.unknown(message: "") }
        }

        await store.send(.path(.element(id: 0, action: .poster(.delegate(.nextRequested))))) {
            $0.submittingID = 0
            $0.path[id: 0, case: \.poster]?.isSubmitting = true
        }
        await store.receive(.createResponse(.failure(.unknown(message: "")))) {
            $0.submittingID = nil
            $0.path[id: 0, case: \.poster]?.isSubmitting = false
            $0.path[id: 0, case: \.poster]?.screen = .actionFailed(
                message: CreateMeetingFlowFeature.defaultFailureMessage
            )
        }
    }

    func test_만들기가_실패해도_서버_문구는_띄우지_않고_만들기_문구를_띄운다() async {
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                form: completeForm(linked: nil),
                path: StackState([.poster(PosterFeature.State())])
            )
        ) {
            CreateMeetingFlowFeature()
        } withDependencies: {
            $0.calendar = CreateMeetingFixtures.calendar
            $0.meetingClient.create = { _ in throw MeetingError.validation(message: "이미 시작된 모임이에요") }
        }

        await store.send(.path(.element(id: 0, action: .poster(.delegate(.nextRequested))))) {
            $0.submittingID = 0
            $0.path[id: 0, case: \.poster]?.isSubmitting = true
        }
        await store.receive(.createResponse(.failure(.validation(message: "이미 시작된 모임이에요")))) {
            $0.submittingID = nil
            $0.path[id: 0, case: \.poster]?.isSubmitting = false
            $0.path[id: 0, case: \.poster]?.screen = .actionFailed(
                message: CreateMeetingFlowFeature.defaultFailureMessage
            )
        }
    }

    func test_앵콜에서_시리즈만_실패하면_모임은_만든_것으로_올리고_시리즈_실패를_알린다() async {
        let linked = CreateMeetingFixtures.meeting(id: "previous-1")
        let store = TestStore(
            initialState: CreateMeetingFlowFeature.State(
                form: completeForm(linked: linked),
                path: StackState([
                    .poster(PosterFeature.State()),
                    .seriesInfo(SeriesInfoFeature.State(title: "케이크 시리즈")),
                ])
            )
        ) {
            CreateMeetingFlowFeature()
        } withDependencies: { [created] in
            $0.calendar = CreateMeetingFixtures.calendar
            $0.meetingClient.createEncore = { _ in .meetingOnly(created, .network) }
        }

        let next = SeriesInfoFeature.Action.delegate(.nextRequested(title: "케이크 시리즈", intro: nil))
        await store.send(.path(.element(id: 1, action: .seriesInfo(next)))) {
            $0.submittingID = 1
            $0.path[id: 1, case: \.seriesInfo]?.isSubmitting = true
        }
        await store.receive(.encoreResponse(.success(.meetingOnly(created, .network)))) {
            $0.submittingID = nil
        }
        await store.receive(.delegate(.createdWithoutSeries(created)))
    }
}

extension CreateMeetingFlowFeatureTests {
    func test_입력에서_닫기를_올리면_흐름도_닫기를_올린다() async {
        let store = TestStore(initialState: CreateMeetingFlowFeature.State()) {
            CreateMeetingFlowFeature()
        }

        await store.send(.form(.delegate(.closeRequested)))
        await store.receive(.delegate(.closed))
    }

    private func completeForm(linked: Meeting?) -> MeetingFormFeature.State {
        var form = MeetingFormFeature.State()
        form.linkedMeeting = linked
        form.category = Interest(id: "food", name: "푸드/드링크")
        form.title = "홀사이즈 케이크 먹는 모임"
        form.startDay = DesignCalendarDay(year: 2026, month: 8, day: 25)
        form.startTime = DesignClockTime(hour: 19, minute: 0)
        form.place = CreateMeetingFixtures.place
        form.capacity = 14
        return form
    }
}

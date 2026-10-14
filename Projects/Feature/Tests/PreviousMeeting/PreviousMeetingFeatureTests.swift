import Domain
@testable import Feature
import ThirdParty
import XCTest

@MainActor
final class PreviousMeetingFeatureTests: XCTestCase {
    func test_처음_열면_최신순으로_내가_연_모임_첫_10개를_요청한다() async {
        let requested = LockIsolated<[PageRequest]>([])
        let meetings = [CreateMeetingFixtures.meeting(id: "m1"), CreateMeetingFixtures.meeting(id: "m2")]
        let next = PageRequest(page: 1, size: 10)
        let store = TestStore(initialState: PreviousMeetingFeature.State()) {
            PreviousMeetingFeature()
        } withDependencies: {
            $0.meetingClient.hostedMeetings = { request in
                requested.withValue { $0.append(request) }
                return Page(items: meetings, next: next)
            }
        }

        await store.send(.task) {
            $0.isLoadingLatest = true
        }
        await store.receive(.latestLoaded(.success(Page(items: meetings, next: next)))) {
            $0.isLoadingLatest = false
            $0.latest = meetings
            $0.latestNext = next
        }
        XCTAssertEqual(requested.value, [MeetingClient.hostedMeetingsFirstPage])
    }

    func test_최신순_마지막_카드가_보이면_다음_페이지를_요청하고_겹친_모임은_거른다() async {
        let first = CreateMeetingFixtures.meeting(id: "m1")
        let third = CreateMeetingFixtures.meeting(id: "m3")
        let next = PageRequest(page: 1, size: 10)
        let requested = LockIsolated<[PageRequest]>([])
        var state = PreviousMeetingFeature.State()
        state.latest = [first]
        state.latestNext = next
        let store = TestStore(initialState: state) {
            PreviousMeetingFeature()
        } withDependencies: {
            $0.meetingClient.hostedMeetings = { request in
                requested.withValue { $0.append(request) }
                return Page(items: [first, third], next: nil)
            }
        }

        await store.send(.lastMeetingAppeared) {
            $0.isLoadingLatest = true
        }
        await store.receive(.latestLoaded(.success(Page(items: [first, third], next: nil)))) {
            $0.isLoadingLatest = false
            $0.latest = [first, third]
            $0.latestNext = nil
        }
        XCTAssertEqual(requested.value, [next])
    }

    func test_시리즈별을_고르면_내가_연_시리즈_첫_페이지를_요청한다() async {
        let hosted = HostedSeries(
            series: CreateMeetingFixtures.series(),
            recentMeetings: [CreateMeetingFixtures.episode(12)]
        )
        let requested = LockIsolated<[PageRequest]>([])
        var state = PreviousMeetingFeature.State()
        state.latest = [CreateMeetingFixtures.meeting()]
        let store = TestStore(initialState: state) {
            PreviousMeetingFeature()
        } withDependencies: {
            $0.seriesClient.hostedSeries = { request in
                requested.withValue { $0.append(request) }
                return Page(items: [hosted], next: nil)
            }
        }

        await store.send(.tabSelected(.series)) {
            $0.tab = .series
            $0.isLoadingSeries = true
        }
        await store.receive(.seriesLoaded(.success(Page(items: [hosted], next: nil)))) {
            $0.isLoadingSeries = false
            $0.hostedSeries = [hosted]
            $0.seriesNext = nil
        }
        XCTAssertEqual(requested.value, [PageRequest.first])
    }

    func test_시리즈_더보기는_5개부터_요청하고_이미_보인_회차는_거른다() async {
        let hosted = HostedSeries(
            series: CreateMeetingFixtures.series(episodeCount: 12),
            recentMeetings: [12, 11, 10].map { CreateMeetingFixtures.episode($0) }
        )
        let loaded = [10, 9, 8, 7, 6].map { CreateMeetingFixtures.episode($0) }
        let next = PageRequest(page: 1, size: 5)
        let requested = LockIsolated<[String]>([])
        var state = PreviousMeetingFeature.State(tab: .series)
        state.hostedSeries = [hosted]
        state.seriesNext = nil
        state.expandedSeriesIDs = ["series-1"]
        let store = TestStore(initialState: state) {
            PreviousMeetingFeature()
        } withDependencies: {
            $0.seriesClient.episodes = { seriesID, request in
                requested.withValue { $0.append("\(seriesID) \(request.page) \(request.size)") }
                return Page(items: loaded, next: next)
            }
        }

        await store.send(.moreEpisodesTapped("series-1"))
        await store.receive(.moreEpisodesLoaded(seriesID: "series-1", .success(Page(items: loaded, next: next)))) {
            $0.moreEpisodes["series-1"] = [9, 8, 7, 6].map { CreateMeetingFixtures.episode($0) }
            $0.moreEpisodesNext["series-1"] = next
        }
        XCTAssertEqual(requested.value, ["series-1 0 5"])
        XCTAssertEqual(SeriesClient.moreEpisodesFirstPage, PageRequest(page: 0, size: 5))
    }

    func test_모임을_고르고_다음을_누르면_고른_모임을_올린다() async {
        let chosen = CreateMeetingFixtures.meeting(id: "m2")
        var state = PreviousMeetingFeature.State()
        state.latest = [CreateMeetingFixtures.meeting(id: "m1"), chosen]
        let store = TestStore(initialState: state) {
            PreviousMeetingFeature()
        }

        await store.send(.meetingTapped("m2")) {
            $0.selectedMeetingID = "m2"
        }
        await store.send(.nextTapped)
        await store.receive(.delegate(.meetingChosen(chosen)))
    }

    func test_모임을_고르지_않으면_다음을_눌러도_아무_일도_없다() async {
        var state = PreviousMeetingFeature.State()
        state.latest = [CreateMeetingFixtures.meeting()]
        let store = TestStore(initialState: state) {
            PreviousMeetingFeature()
        }

        await store.send(.nextTapped)
    }

    func test_처음_불러오기가_실패하면_불러오기_실패_화면을_띄운다() async {
        let store = TestStore(initialState: PreviousMeetingFeature.State()) {
            PreviousMeetingFeature()
        } withDependencies: {
            $0.meetingClient.hostedMeetings = { _ in throw MeetingError.network }
        }

        await store.send(.task) {
            $0.isLoadingLatest = true
        }
        await store.receive(.latestLoaded(.failure(.network))) {
            $0.isLoadingLatest = false
            $0.screen = .loadFailed(message: "네트워크 연결을 확인해 주세요")
        }
    }

    func test_서버_문구가_비면_기본_문구로_불러오기_실패를_띄운다() async {
        let store = TestStore(initialState: PreviousMeetingFeature.State()) {
            PreviousMeetingFeature()
        } withDependencies: {
            $0.meetingClient.hostedMeetings = { _ in throw MeetingError.unknown(message: "") }
        }

        await store.send(.task) {
            $0.isLoadingLatest = true
        }
        await store.receive(.latestLoaded(.failure(.unknown(message: "")))) {
            $0.isLoadingLatest = false
            $0.screen = .loadFailed(message: PreviousMeetingFeature.defaultLoadFailureMessage)
        }
    }
}

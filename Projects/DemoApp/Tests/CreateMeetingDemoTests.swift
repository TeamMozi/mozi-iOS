import Domain
import Feature
@testable import MoziDemoKit
import ThirdParty
import XCTest

@MainActor
final class CreateMeetingDemoTests: XCTestCase {
    private let posterURL = URL(filePath: "/demo-poster.jpg")
    private let now = Date(timeIntervalSince1970: 1_790_000_000)
    private let calendar = Calendar(identifier: .gregorian)

    func test_처음_만들기는_지난_모임이_없다() async throws {
        let client = CreateMeetingDemoClients.meetingClient(for: .firstCreate, posterURL: posterURL)
        let page = try await client.hostedMeetings(page: MeetingClient.hostedMeetingsFirstPage)

        XCTAssertTrue(page.items.isEmpty)
    }

    func test_지난_모임_있음은_시리즈에_안_묶인_모임과_묶인_모임을_함께_보인다() async throws {
        let client = CreateMeetingDemoClients.meetingClient(for: .previousMeeting, posterURL: posterURL)
        let page = try await client.hostedMeetings(page: MeetingClient.hostedMeetingsFirstPage)

        XCTAssertTrue(page.items.contains { $0.episode == nil })
        XCTAssertTrue(page.items.contains { $0.episode != nil })
        XCTAssertNil(page.items.first?.posterURL)
    }

    func test_지난_포스터_불러오기는_지난_모임마다_포스터가_있다() async throws {
        let client = CreateMeetingDemoClients.meetingClient(for: .previousPoster, posterURL: posterURL)
        let page = try await client.hostedMeetings(page: MeetingClient.hostedMeetingsFirstPage)

        XCTAssertFalse(page.items.isEmpty)
        XCTAssertTrue(page.items.allSatisfy { $0.posterURL == posterURL })
    }

    func test_만들기_실패는_만들기와_앵콜이_모두_실패한다() async {
        let client = CreateMeetingDemoClients.meetingClient(for: .createFailed, posterURL: posterURL)

        do {
            _ = try await client.create(draft: draft())
            XCTFail("만들기가 실패해야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .unknown(message: ""))
        }
        do {
            _ = try await client.createEncore(draft: encoreDraft())
            XCTFail("앵콜이 실패해야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .unknown(message: ""))
        }
    }

    func test_시리즈만_실패는_앵콜이_모임만_만든다() async throws {
        let client = CreateMeetingDemoClients.meetingClient(for: .seriesOnlyFailed, posterURL: posterURL)
        let result = try await client.createEncore(draft: encoreDraft())

        guard case let .meetingOnly(meeting, error) = result else {
            return XCTFail("meetingOnly 가 와야 한다")
        }
        XCTAssertEqual(meeting.title, "주말 아침 러닝 크루")
        XCTAssertEqual(error, .network)
    }

    func test_장소_검색_0건은_어떤_검색어에도_빈_목록이다() async throws {
        let places = try await CreateMeetingDemoClients.placeClient(for: .placeEmpty).search(query: "서울")

        XCTAssertTrue(places.isEmpty)
    }

    func test_다른_상태의_장소_검색은_어떤_검색어에도_가짜_장소_넷을_모두_돌려준다() async throws {
        let client = CreateMeetingDemoClients.placeClient(for: .previousMeeting)

        let matching = try await client.search(query: "서울")
        let unrelated = try await client.search(query: "없는 장소")

        XCTAssertEqual(matching.count, 4)
        XCTAssertEqual(unrelated, matching)
    }

    func test_만든_뒤는_시트를_닫고_만든_모임_한_줄로_시작한다() {
        let state = start(.created)

        XCTAssertNil(state.flow)
        XCTAssertEqual(state.createdLine, "만든 모임 · 홀사이즈 케이크 먹는 모임")
    }

    func test_빈_화면에서_처음_만들기는_빈_입력에서_시작한다() throws {
        let flow = try XCTUnwrap(start(.firstCreate).flow)

        XCTAssertTrue(flow.path.isEmpty)
        XCTAssertFalse(flow.form.isComplete)
    }

    func test_입력_다_채운_모임_만들기는_필수_다섯_칸이_찬_입력에서_시작한다() throws {
        let flow = try XCTUnwrap(start(.filledForm).flow)

        XCTAssertTrue(flow.path.isEmpty)
        XCTAssertTrue(flow.form.isComplete)
        XCTAssertGreaterThan(try XCTUnwrap(flow.form.startAt(in: calendar)), now)
    }

    func test_지난_모임_불러오기는_모임_불러오기_화면에서_시작한다() throws {
        let flow = try XCTUnwrap(start(.previousMeeting).flow)

        XCTAssertEqual(flow.path.count, 1)
        XCTAssertNotNil(flow.path.last?.previousMeeting)
    }

    func test_지난_포스터_이어_쓰기는_지난_포스터를_고른_포스터_화면에서_시작한다() throws {
        let flow = try XCTUnwrap(start(.previousPoster).flow)

        XCTAssertEqual(flow.path.last?.poster?.selection.image, .previous(posterURL))
        XCTAssertEqual(flow.poster.image, .previous(posterURL))
        XCTAssertTrue(flow.form.isComplete)
    }

    func test_만들기_실패는_입력이_찬_포스터_화면에서_시작한다() throws {
        let flow = try XCTUnwrap(start(.createFailed).flow)

        XCTAssertNotNil(flow.path.last?.poster)
        XCTAssertTrue(flow.form.isComplete)
        XCTAssertFalse(flow.isEncore)
    }

    func test_연결만_실패는_시리즈명이_찬_시리즈_정보_화면에서_시작한다() throws {
        let flow = try XCTUnwrap(start(.seriesOnlyFailed).flow)

        XCTAssertEqual(flow.path.last?.seriesInfo?.title, "케이크 시리즈")
        XCTAssertTrue(flow.isEncore)
        XCTAssertTrue(flow.form.isComplete)
    }

    func test_장소_검색_결과_없음은_장소_선택_화면에서_시작한다() throws {
        let flow = try XCTUnwrap(start(.placeEmpty).flow)

        XCTAssertNotNil(flow.path.last?.placeSearch)
    }

    func test_모임이_올라오면_시트를_닫고_한_줄로_보인다() async {
        let meeting = CreateMeetingDemoData.unboundMeeting(posterURL: nil)
        let store = TestStore(initialState: DemoCreateMeetingFeature.State()) {
            DemoCreateMeetingFeature()
        }

        await store.send(.flow(.presented(.delegate(.created(meeting))))) {
            $0.flow = nil
            $0.createdMeetingTitle = meeting.title
        }
    }

    func test_시리즈만_실패해_올라오면_시트를_닫고_안내를_띄운다() async {
        let meeting = CreateMeetingDemoData.unboundMeeting(posterURL: nil)
        let store = TestStore(initialState: DemoCreateMeetingFeature.State()) {
            DemoCreateMeetingFeature()
        }

        await store.send(.flow(.presented(.delegate(.createdWithoutSeries(meeting))))) {
            $0.flow = nil
            $0.createdMeetingTitle = meeting.title
            $0.screen = .actionFailed(message: CreateMeetingFlowFeature.seriesFailedNotice)
        }
        await store.send(.noticeDismissed) {
            $0.screen = .idle
        }
    }

    private func start(_ state: CreateMeetingDemoState) -> DemoCreateMeetingFeature.State {
        state.initialState(posterURL: posterURL, now: now, calendar: calendar)
    }

    private func draft() -> MeetingDraft {
        MeetingDraft(
            title: "주말 아침 러닝 크루",
            intro: nil,
            detail: nil,
            poster: .keep,
            backgroundMusicID: nil,
            startAt: Date(timeIntervalSince1970: 1_893_456_000),
            place: Place(name: "서울숲", address: "서울 성동구 뚝섬로 273", latitude: 37.5444, longitude: 127.0374),
            capacity: 10,
            ageRange: AgeRange(minAge: nil, maxAge: nil),
            genderRestriction: .any,
            categoryID: "sports",
            seriesID: nil,
            joinQuestions: []
        )
    }

    private func encoreDraft() -> EncoreDraft {
        EncoreDraft(
            meeting: draft(),
            previousMeetingID: "demo-meeting-unbound",
            seriesTitle: "케이크 시리즈",
            seriesIntro: nil
        )
    }
}

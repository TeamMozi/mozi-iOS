import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

@MainActor
final class MeetingDetailFeatureTests: XCTestCase {
    // MARK: 읽기

    func test_모임장이_열면_모임을_읽고_모임장을_뺀_멤버와_스냅포인트를_덧붙여_읽는다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let snapPoints = [MeetingDetailFixtures.snapPoint(1)]
        let store = TestStore(initialState: MeetingDetailFeature.State(meetingID: meeting.id)) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.meeting = { _ in meeting }
            $0.meetingClient.members = { _, status in
                XCTAssertEqual(status, .joined)
                return [MeetingDetailFixtures.hostMember, MeetingDetailFixtures.member(1)]
            }
            $0.snapPointClient.snapPoints = { _ in snapPoints }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        await store.receive(.meetingLoaded(.success(meeting))) {
            $0.screen = .idle
            $0.meeting = meeting
        }
        let extras = MeetingDetailFeature.Extras(
            members: [MeetingDetailFixtures.member(1)],
            snapPoints: snapPoints,
            series: nil,
            episodes: []
        )
        await store.receive(.extrasLoaded(extras)) {
            $0.members = [MeetingDetailFixtures.member(1)]
            $0.snapPoints = snapPoints
        }
    }

    func test_신청_전이면_스냅포인트를_읽지_않는다() async throws {
        // snapPointClient 를 채우지 않는다. 부르면 테스트가 깨진다.
        let meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none)
        let store = TestStore(initialState: MeetingDetailFeature.State(meetingID: meeting.id)) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.meeting = { _ in meeting }
            $0.meetingClient.members = { _, _ in [] }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        await store.receive(.meetingLoaded(.success(meeting))) {
            $0.screen = .idle
            $0.meeting = meeting
        }
        await store.receive(.extrasLoaded(.empty))
        XCTAssertFalse(store.state.showsSnapPoints)
    }

    func test_시리즈에_묶인_모임은_시리즈와_회차를_읽는다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.member, seriesID: "series-1")
        let series = MeetingDetailFixtures.series()
        let store = TestStore(initialState: MeetingDetailFeature.State(meetingID: meeting.id)) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.meeting = { _ in meeting }
            $0.meetingClient.members = { _, _ in [] }
            $0.snapPointClient.snapPoints = { _ in [] }
            $0.seriesClient.series = { id in
                XCTAssertEqual(id, "series-1")
                return series
            }
            $0.seriesClient.episodes = { _, page in
                XCTAssertEqual(page, .first)
                return Page(items: [meeting], next: nil)
            }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        await store.receive(.meetingLoaded(.success(meeting))) {
            $0.screen = .idle
            $0.meeting = meeting
        }
        let extras = MeetingDetailFeature.Extras(members: [], snapPoints: [], series: series, episodes: [meeting])
        await store.receive(.extrasLoaded(extras)) {
            $0.series = series
            $0.episodes = [meeting]
        }
        XCTAssertTrue(store.state.isSeriesEnabled)
    }

    func test_모임을_못_읽으면_불러오기_실패를_띄우고_다시_시도하면_다시_읽는다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none)
        let fails = LockIsolated(true)
        let store = TestStore(initialState: MeetingDetailFeature.State(meetingID: meeting.id)) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.meeting = { _ in
                if fails.value { throw MeetingError.network }
                return meeting
            }
            $0.meetingClient.members = { _, _ in [] }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        await store.receive(.meetingLoaded(.failure(.network))) {
            $0.screen = .loadFailed(message: "네트워크 연결을 확인해 주세요")
        }
        fails.setValue(false)
        await store.send(.retryTapped) {
            $0.screen = .loading
        }
        await store.receive(.meetingLoaded(.success(meeting))) {
            $0.screen = .idle
            $0.meeting = meeting
        }
        await store.receive(.extrasLoaded(.empty))
    }

    // MARK: 관점

    func test_모집중이고_정원이_남은_신청_전_모임만_신청하기를_보인다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none)
        XCTAssertTrue(state.canApply)

        state.meeting?.status = .closed
        XCTAssertFalse(state.canApply, "모집 마감")
        state.meeting?.status = .ended
        XCTAssertFalse(state.canApply, "종료")
        state.meeting?.status = .recruiting
        state.meeting?.joinedCount = 8
        XCTAssertFalse(state.canApply, "정원 참")
        state.meeting?.joinedCount = 5
        state.meeting?.myParticipation = .pending
        XCTAssertFalse(state.canApply, "승인 대기")
    }

    func test_스냅포인트_구간은_모임장과_멤버만_본다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(.host)
        XCTAssertTrue(state.showsSnapPoints)
        state.meeting?.myParticipation = .member
        XCTAssertTrue(state.showsSnapPoints)
        state.meeting?.myParticipation = .pending
        XCTAssertFalse(state.showsSnapPoints)
        state.meeting?.myParticipation = MyParticipation.none
        XCTAssertFalse(state.showsSnapPoints)
    }
}

extension MeetingDetailFeatureTests {
    // MARK: 신청

    func test_가입_질문이_없는_바로_가입_모임에_신청하면_멤버가_되고_스냅포인트를_읽는다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(
            MyParticipation.none,
            joinType: .instant,
            joinQuestions: []
        )
        let snapPoints = [MeetingDetailFixtures.snapPoint(1)]
        let me = MeetingDetailFixtures.member(9)
        var state = MeetingDetailFeature.State(meetingID: meeting.id)
        state.meeting = meeting
        state.members = [MeetingDetailFixtures.member(1)]
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.join = { _, answers in
                XCTAssertEqual(answers, [])
                return .member
            }
            $0.meetingClient.members = { _, status in
                XCTAssertEqual(status, .joined)
                return [MeetingDetailFixtures.hostMember, MeetingDetailFixtures.member(1), me]
            }
            $0.snapPointClient.snapPoints = { _ in snapPoints }
        }

        await store.send(.joinTapped) {
            $0.isRequesting = true
        }
        await store.receive(.joinResponse(.success(.member))) {
            $0.isRequesting = false
            $0.meeting?.myParticipation = .member
            $0.meeting?.joinedCount = 6
        }
        await store.receive(.membersLoaded([MeetingDetailFixtures.member(1), me])) {
            $0.members = [MeetingDetailFixtures.member(1), me]
        }
        await store.receive(.snapPointsLoaded(snapPoints)) {
            $0.snapPoints = snapPoints
        }
    }

    func test_가입_질문이_있으면_시트에서_답을_받아_보내고_승인_대기가_된다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none)
        var state = MeetingDetailFeature.State(meetingID: meeting.id)
        state.meeting = meeting
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.join = { id, answers in
                XCTAssertEqual(id, MeetingDetailFixtures.meetingID)
                XCTAssertEqual(answers, ["포피파"])
                return .pending
            }
        }

        await store.send(.joinTapped) {
            $0.joinAnswers = [""]
        }
        await store.send(.joinAnswerChanged(index: 0, text: "  포피파 ")) {
            $0.joinAnswers = ["  포피파 "]
        }
        XCTAssertTrue(store.state.canSubmitJoin)
        await store.send(.joinSubmitTapped) {
            $0.isRequesting = true
        }
        await store.receive(.joinResponse(.success(.pending))) {
            $0.isRequesting = false
            $0.joinAnswers = nil
            $0.meeting?.myParticipation = .pending
        }
    }

    func test_답이_공백뿐이면_신청하기가_눌리지_않는다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none)
        state.joinAnswers = ["   "]
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        }

        XCTAssertFalse(store.state.canSubmitJoin)
        await store.send(.joinSubmitTapped)
    }

    func test_신청_요청_중에_시트를_닫아도_응답이_오면_관점이_바뀐다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none)
        state.joinAnswers = ["포피파"]
        // 응답이 시트를 닫은 뒤에 오도록 시계를 넘길 때까지 기다린다.
        let clock = TestClock()
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.join = { _, _ in
                try await clock.sleep(for: .seconds(1))
                return .pending
            }
        }

        await store.send(.joinSubmitTapped) {
            $0.isRequesting = true
        }
        await store.send(.joinSheetDismissed) {
            $0.joinAnswers = nil
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.joinResponse(.success(.pending))) {
            $0.isRequesting = false
            $0.meeting?.myParticipation = .pending
        }
    }

    func test_신청_요청_중에_다시_눌러도_한_번만_보낸다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none, joinQuestions: [])
        let calls = LockIsolated(0)
        let clock = TestClock()
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.join = { _, _ in
                calls.withValue { $0 += 1 }
                try await clock.sleep(for: .seconds(1))
                return .pending
            }
        }

        await store.send(.joinTapped) {
            $0.isRequesting = true
        }
        await store.send(.joinTapped)
        await clock.advance(by: .seconds(1))
        await store.receive(.joinResponse(.success(.pending))) {
            $0.isRequesting = false
            $0.meeting?.myParticipation = .pending
        }
        XCTAssertEqual(calls.value, 1)
    }

    func test_모집_마감된_모임은_신청하기를_눌러도_아무_일도_없다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none, status: .closed)
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        }

        await store.send(.joinTapped)
    }

    func test_참여_조건_미달이면_신청_뒤_오류를_띄운다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none, joinQuestions: [])
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.join = { _, _ in throw MeetingError.joinRestricted }
        }

        await store.send(.joinTapped) {
            $0.isRequesting = true
        }
        await store.receive(.joinResponse(.failure(.joinRestricted))) {
            $0.isRequesting = false
            $0.screen = .actionFailed(message: "참여 조건이 맞지 않아 신청할 수 없어요")
        }
        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
    }

    // MARK: 나가기·신청 취소

    func test_멤버가_나가면_신청_전_관점이_되고_참여_인원이_줄고_스냅포인트를_비운다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(.member)
        state.snapPoints = [MeetingDetailFixtures.snapPoint(1)]
        let me = MeetingDetailFixtures.member(9)
        state.members = [MeetingDetailFixtures.member(1), me]
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.leave = { _ in }
            $0.meetingClient.members = { _, status in
                XCTAssertEqual(status, .joined)
                return [MeetingDetailFixtures.hostMember, MeetingDetailFixtures.member(1)]
            }
        }

        await store.send(.leaveTapped) {
            $0.isRequesting = true
        }
        await store.receive(.leaveResponse(.success(.member))) {
            $0.isRequesting = false
            $0.meeting?.myParticipation = MyParticipation.none
            $0.meeting?.joinedCount = 4
            $0.snapPoints = []
        }
        await store.receive(.membersLoaded([MeetingDetailFixtures.member(1)])) {
            $0.members = [MeetingDetailFixtures.member(1)]
        }
        XCTAssertTrue(store.state.canApply)
    }

    func test_승인_대기에서_신청을_취소하면_신청_전_관점이_되고_참여_인원은_그대로다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(.pending)
        state.members = [MeetingDetailFixtures.member(1)]
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.leave = { _ in }
            $0.meetingClient.members = { _, _ in [MeetingDetailFixtures.member(1)] }
        }

        await store.send(.leaveTapped) {
            $0.isRequesting = true
        }
        await store.receive(.leaveResponse(.success(.pending))) {
            $0.isRequesting = false
            $0.meeting?.myParticipation = MyParticipation.none
        }
        // 승인 대기는 확정 멤버가 아니어서 다시 읽어도 목록이 그대로다.
        await store.receive(.membersLoaded([MeetingDetailFixtures.member(1)]))
    }

    func test_모임장과_신청_전은_나가기를_눌러도_아무_일도_없다() async throws {
        for participation in [MyParticipation.host, MyParticipation.none] {
            var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
            state.meeting = try await MeetingDetailFixtures.meeting(participation)
            let store = TestStore(initialState: state) {
                MeetingDetailFeature()
            }
            await store.send(.leaveTapped)
        }
    }

    // MARK: 위쪽 버튼

    func test_종을_누르면_알림_요청을_켜고_다시_누르면_끈다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none)
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient.requestNotification = { _ in }
            $0.meetingClient.cancelNotificationRequest = { _ in }
        }

        await store.send(.bellTapped) {
            $0.isRequesting = true
        }
        await store.receive(.notificationToggled(.success(true))) {
            $0.isRequesting = false
            $0.meeting?.isNotificationRequested = true
            $0.meeting?.notificationRequestCount = 5
        }
        await store.send(.bellTapped) {
            $0.isRequesting = true
        }
        await store.receive(.notificationToggled(.success(false))) {
            $0.isRequesting = false
            $0.meeting?.isNotificationRequested = false
            $0.meeting?.notificationRequestCount = 4
        }
    }

    func test_메뉴는_모임장만_모임_관리를_올린다() async throws {
        var hostState = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        hostState.meeting = try await MeetingDetailFixtures.meeting(.host)
        let hostStore = TestStore(initialState: hostState) {
            MeetingDetailFeature()
        }
        await hostStore.send(.menuTapped)
        await hostStore.receive(.delegate(.managementRequested))

        var memberState = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        memberState.meeting = try await MeetingDetailFixtures.meeting(.member)
        let memberStore = TestStore(initialState: memberState) {
            MeetingDetailFeature()
        }
        await memberStore.send(.menuTapped)
    }

    func test_뒤로_채팅_필름은_delegate로_올린다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(.member)
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        }

        await store.send(.backTapped)
        await store.receive(.delegate(.closeRequested))
        await store.send(.chatTapped)
        await store.receive(.delegate(.chatRequested(meetingID: MeetingDetailFixtures.meetingID)))
        await store.send(.filmTapped)
        await store.receive(.delegate(.filmRequested(meetingID: MeetingDetailFixtures.meetingID)))
    }

    func test_시리즈_아이콘은_시리즈가_있을_때만_올린다() async throws {
        var state = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(.member)
        let store = TestStore(initialState: state) {
            MeetingDetailFeature()
        }
        XCTAssertFalse(store.state.isSeriesEnabled)
        await store.send(.seriesTapped)

        var seriesState = MeetingDetailFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        seriesState.meeting = try await MeetingDetailFixtures.meeting(.member, seriesID: "series-1")
        let seriesStore = TestStore(initialState: seriesState) {
            MeetingDetailFeature()
        }
        await seriesStore.send(.seriesTapped)
        await seriesStore.receive(.delegate(.seriesRequested(seriesID: "series-1")))
    }
}

private extension MeetingDetailFeature.Extras {
    static let empty = MeetingDetailFeature.Extras(members: [], snapPoints: [], series: nil, episodes: [])
}

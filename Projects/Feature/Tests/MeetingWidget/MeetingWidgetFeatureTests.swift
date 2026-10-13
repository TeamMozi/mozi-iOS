import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

@MainActor
final class MeetingWidgetFeatureTests: XCTestCase {
    /// 2026-07-16 14:40 KST
    private let sentAt = Date(timeIntervalSince1970: 1_784_180_400)

    private func loadedState(
        status: MeetingStatus = .recruiting,
        snapPoints: [SnapPoint]
    ) async throws -> MeetingWidgetFeature.State {
        var state = MeetingWidgetFeature.State(meetingID: MeetingDetailFixtures.meetingID)
        state.meeting = try await MeetingDetailFixtures.meeting(.host, status: status)
        state.snapPoints = snapPoints
        return state
    }

    func test_열면_모임과_스냅포인트와_모임장을_뺀_멤버를_읽는다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let snapPoints = [MeetingDetailFixtures.snapPoint(1)]
        let store = TestStore(initialState: MeetingWidgetFeature.State(meetingID: meeting.id)) {
            MeetingWidgetFeature()
        } withDependencies: {
            $0.meetingClient.meeting = { _ in meeting }
            $0.meetingClient.members = { _, _ in [MeetingDetailFixtures.hostMember, MeetingDetailFixtures.member(1)] }
            $0.snapPointClient.snapPoints = { _ in snapPoints }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        let loaded = MeetingWidgetFeature.Loaded(
            meeting: meeting,
            snapPoints: snapPoints,
            members: [MeetingDetailFixtures.member(1)]
        )
        await store.receive(.loaded(.success(loaded))) {
            $0.screen = .idle
            $0.meeting = meeting
            $0.snapPoints = snapPoints
            $0.members = [MeetingDetailFixtures.member(1)]
        }
    }

    func test_알림을_보내면_그_줄이_보낸_시각과_참여수를_갖고_흐름에_올린다() async throws {
        let unsent = MeetingDetailFixtures.snapPoint(1)
        let sent = MeetingDetailFixtures.snapPoint(1, sentAt: sentAt, participantCount: 8)
        let initialState = try await loadedState(snapPoints: [unsent])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        } withDependencies: {
            $0.snapPointClient.sendNotification = { meetingID, snapPointID in
                XCTAssertEqual(meetingID, MeetingDetailFixtures.meetingID)
                XCTAssertEqual(snapPointID, unsent.id)
                return sent
            }
        }

        await store.send(.notifyTapped(id: unsent.id)) {
            $0.sendingSnapPointID = unsent.id
        }
        await store.receive(.notified(sent)) {
            $0.sendingSnapPointID = nil
            $0.snapPoints = [sent]
        }
        await store.receive(.delegate(.snapPointsChanged([sent])))
    }

    func test_알림은_아무_순서로나_보낸다() async throws {
        let first = MeetingDetailFixtures.snapPoint(1)
        let third = MeetingDetailFixtures.snapPoint(3)
        let sentThird = MeetingDetailFixtures.snapPoint(3, sentAt: sentAt, participantCount: 2)
        let initialState = try await loadedState(snapPoints: [first, third])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        } withDependencies: {
            $0.snapPointClient.sendNotification = { _, _ in sentThird }
        }

        await store.send(.notifyTapped(id: third.id)) {
            $0.sendingSnapPointID = third.id
        }
        await store.receive(.notified(sentThird)) {
            $0.sendingSnapPointID = nil
            $0.snapPoints = [first, sentThird]
        }
        await store.receive(.delegate(.snapPointsChanged([first, sentThird])))
    }

    func test_보낸_스냅포인트는_다시_보내지_않는다() async throws {
        let sent = MeetingDetailFixtures.snapPoint(1, sentAt: sentAt, participantCount: 8)
        let initialState = try await loadedState(snapPoints: [sent])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        }
        XCTAssertFalse(store.state.canNotify(sent))
        await store.send(.notifyTapped(id: sent.id))
    }

    func test_알림을_보내는_중에는_다른_알림을_보내지_않는다() async throws {
        let first = MeetingDetailFixtures.snapPoint(1)
        let second = MeetingDetailFixtures.snapPoint(2)
        var state = try await loadedState(snapPoints: [first, second])
        state.sendingSnapPointID = first.id
        let store = TestStore(initialState: state) {
            MeetingWidgetFeature()
        }
        await store.send(.notifyTapped(id: second.id))
        await store.send(.notifyTapped(id: first.id))
    }

    func test_알림이_실패하면_보내지_않은_채로_오류를_띄운다() async throws {
        let unsent = MeetingDetailFixtures.snapPoint(1)
        let initialState = try await loadedState(snapPoints: [unsent])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        } withDependencies: {
            $0.snapPointClient.sendNotification = { _, _ in throw SnapPointError.network }
        }

        await store.send(.notifyTapped(id: unsent.id)) {
            $0.sendingSnapPointID = unsent.id
        }
        await store.receive(.notifyFailed(.network)) {
            $0.sendingSnapPointID = nil
            $0.screen = .actionFailed(message: "네트워크 연결을 확인해 주세요")
        }
    }

    func test_모임_종료는_확인_창을_띄우고_확인하면_종료해_흐름에_올린다() async throws {
        let ended = try await MeetingDetailFixtures.meeting(.host, status: .ended)
        let initialState = try await loadedState(status: .closed, snapPoints: [])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        } withDependencies: {
            $0.meetingClient.end = { _ in ended }
        }

        await store.send(.endMenuTapped) {
            $0.isEndConfirmationPresented = true
        }
        await store.send(.endConfirmed) {
            $0.isEndConfirmationPresented = false
            $0.isRequesting = true
        }
        await store.receive(.ended(.success(ended))) {
            $0.isRequesting = false
            $0.meeting = ended
        }
        await store.receive(.delegate(.meetingChanged(ended)))
    }

    func test_종료_확인_창을_닫으면_종료하지_않는다() async throws {
        let initialState = try await loadedState(status: .closed, snapPoints: [])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        }
        await store.send(.endMenuTapped) {
            $0.isEndConfirmationPresented = true
        }
        await store.send(.endDismissed) {
            $0.isEndConfirmationPresented = false
        }
    }

    func test_모집_중이면_종료_메뉴를_감추고_종료_요청은_무시한다() async throws {
        let initialState = try await loadedState(status: .recruiting, snapPoints: [])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        } withDependencies: {
            $0.meetingClient.end = { _ in
                XCTFail("모집 중에서는 종료를 요청하지 않는다")
                throw MeetingError.conflict(message: "")
            }
        }
        XCTAssertFalse(store.state.isEndMenuShown)
        XCTAssertFalse(store.state.canEnd)
        XCTAssertTrue(store.state.canManage)
        await store.send(.endMenuTapped)
        await store.send(.endConfirmed)
    }

    func test_모집_마감이면_종료_메뉴를_보이고_누를_수_있다() async throws {
        let state = try await loadedState(status: .closed, snapPoints: [])
        XCTAssertTrue(state.isEndMenuShown)
        XCTAssertTrue(state.canEnd)
    }

    func test_종료된_모임은_알림도_종료도_편집도_막는다() async throws {
        let unsent = MeetingDetailFixtures.snapPoint(1)
        let initialState = try await loadedState(status: .ended, snapPoints: [unsent])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        }
        XCTAssertFalse(store.state.canNotify(unsent))
        XCTAssertFalse(store.state.canManage)
        XCTAssertTrue(store.state.isEndMenuShown)
        XCTAssertFalse(store.state.canEnd)
        await store.send(.notifyTapped(id: unsent.id))
        await store.send(.endMenuTapped)
        await store.send(.editMenuTapped)
    }

    func test_참여_멤버_줄은_보낸_줄에_참여가_1명_이상일_때만_인원을_준다() async throws {
        let state = try await loadedState(snapPoints: [])
        XCTAssertNil(state.shownParticipantCount(MeetingDetailFixtures.snapPoint(1)))
        XCTAssertNil(state.shownParticipantCount(MeetingDetailFixtures.snapPoint(2, sentAt: sentAt)))
        XCTAssertNil(
            state.shownParticipantCount(MeetingDetailFixtures.snapPoint(3, sentAt: sentAt, participantCount: 0))
        )
        XCTAssertEqual(
            state.shownParticipantCount(MeetingDetailFixtures.snapPoint(4, sentAt: sentAt, participantCount: 3)),
            3
        )
    }

    func test_멤버_타일은_격자를_켜고_끄고_전체보기와_편집과_닫기는_올린다() async throws {
        let initialState = try await loadedState(snapPoints: [])
        let store = TestStore(initialState: initialState) {
            MeetingWidgetFeature()
        }
        await store.send(.memberTileTapped) {
            $0.isMemberGridShown = true
        }
        await store.send(.memberTileTapped) {
            $0.isMemberGridShown = false
        }
        await store.send(.memberAllTapped)
        await store.receive(.delegate(.memberManagementRequested))
        await store.send(.editMenuTapped)
        await store.receive(.delegate(.snapPointSettingRequested))
        await store.send(.closeTapped)
        await store.receive(.delegate(.closeRequested))
    }

    func test_모임을_못_읽으면_불러오기_실패를_띄운다() async {
        let store = TestStore(initialState: MeetingWidgetFeature.State(meetingID: MeetingDetailFixtures.meetingID)) {
            MeetingWidgetFeature()
        } withDependencies: {
            $0.meetingClient.meeting = { _ in throw MeetingError.notFound }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        await store.receive(.loaded(.failure(.notFound))) {
            $0.screen = .loadFailed(message: "모임을 불러오지 못했어요")
        }
    }
}

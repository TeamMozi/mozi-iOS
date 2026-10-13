import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

@MainActor
final class MemberManagementFeatureTests: XCTestCase {
    private let host = MeetingHost(
        userID: MeetingDetailFixtures.hostID,
        nickname: "모지장",
        profileImageURL: nil,
        introduction: nil,
        hostedCount: nil,
        participatedCount: nil
    )

    private func loadedState(isEnded: Bool = false) -> MemberManagementFeature.State {
        var state = MemberManagementFeature.State(
            meetingID: MeetingDetailFixtures.meetingID,
            host: host,
            isEnded: isEnded
        )
        state.members = [MeetingDetailFixtures.member(1)]
        state.pending = [MeetingDetailFixtures.member(2, status: .pending)]
        state.hasLoaded = true
        return state
    }

    func test_열면_목록_셋을_읽고_멤버에서_모임장을_뺀다() async {
        let requesters = [MeetingDetailFixtures.member(9)]
        let initial = MemberManagementFeature.State(
            meetingID: MeetingDetailFixtures.meetingID,
            host: host,
            isEnded: false
        )
        let store = TestStore(initialState: initial) {
            MemberManagementFeature()
        } withDependencies: {
            $0.meetingClient.members = { _, status in
                status == .pending
                    ? [MeetingDetailFixtures.member(2, status: .pending)]
                    : [MeetingDetailFixtures.hostMember, MeetingDetailFixtures.member(1)]
            }
            $0.meetingClient.notificationRequesters = { _ in requesters }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        let lists = MemberManagementFeature.Lists(
            members: [MeetingDetailFixtures.member(1)],
            pending: [MeetingDetailFixtures.member(2, status: .pending)],
            notificationRequesters: requesters
        )
        await store.receive(.listsLoaded(.success(lists))) {
            $0.screen = .idle
            $0.hasLoaded = true
            $0.members = lists.members
            $0.pending = lists.pending
            $0.notificationRequesters = requesters
        }
    }

    func test_목록을_못_읽으면_불러오기_실패를_띄운다() async {
        let initial = MemberManagementFeature.State(
            meetingID: MeetingDetailFixtures.meetingID,
            host: host,
            isEnded: false
        )
        let store = TestStore(initialState: initial) {
            MemberManagementFeature()
        } withDependencies: {
            $0.meetingClient.members = { _, _ in throw MeetingError.forbidden }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        await store.receive(.listsLoaded(.failure(.forbidden))) {
            $0.screen = .loadFailed(message: "멤버를 불러오지 못했어요")
        }
    }

    func test_승인하면_승인_대기에서_멤버로_옮기고_흐름에_올린다() async {
        let store = TestStore(initialState: loadedState()) {
            MemberManagementFeature()
        } withDependencies: {
            $0.meetingClient.approve = { meetingID, userID in
                XCTAssertEqual(meetingID, MeetingDetailFixtures.meetingID)
                XCTAssertEqual(userID, "user-2")
            }
        }

        await store.send(.approveTapped(userID: "user-2")) {
            $0.requestingUserIDs = ["user-2"]
        }
        await store.receive(.approved(userID: "user-2")) {
            $0.requestingUserIDs = []
            $0.pending = []
            $0.members = [MeetingDetailFixtures.member(1), MeetingDetailFixtures.member(2)]
        }
        await store.receive(.delegate(.memberApproved(MeetingDetailFixtures.member(2))))
    }

    func test_정원이_차서_승인이_실패하면_승인_대기에_남고_오류를_띄운다() async {
        let store = TestStore(initialState: loadedState()) {
            MemberManagementFeature()
        } withDependencies: {
            $0.meetingClient.approve = { _, _ in throw MeetingError.conflict(message: "") }
        }

        await store.send(.approveTapped(userID: "user-2")) {
            $0.requestingUserIDs = ["user-2"]
        }
        await store.receive(.approveFailed(userID: "user-2", .conflict(message: ""))) {
            $0.requestingUserIDs = []
            $0.screen = .actionFailed(message: "정원이 다 차서 승인할 수 없어요")
        }
        XCTAssertEqual(store.state.pending, [MeetingDetailFixtures.member(2, status: .pending)])
    }

    func test_승인_요청_중에_같은_사람을_다시_눌러도_한_번만_보낸다() async {
        let calls = LockIsolated(0)
        // 두 번째 누름이 응답보다 먼저 오도록 요청을 붙잡아 둔다
        let (gate, release) = AsyncStream<Void>.makeStream()
        let store = TestStore(initialState: loadedState()) {
            MemberManagementFeature()
        } withDependencies: {
            $0.meetingClient.approve = { _, _ in
                calls.withValue { $0 += 1 }
                for await _ in gate {}
            }
        }

        await store.send(.approveTapped(userID: "user-2")) {
            $0.requestingUserIDs = ["user-2"]
        }
        await store.send(.approveTapped(userID: "user-2"))
        release.finish()
        await store.receive(.approved(userID: "user-2")) {
            $0.requestingUserIDs = []
            $0.pending = []
            $0.members = [MeetingDetailFixtures.member(1), MeetingDetailFixtures.member(2)]
        }
        await store.receive(.delegate(.memberApproved(MeetingDetailFixtures.member(2))))
        XCTAssertEqual(calls.value, 1)
    }

    func test_종료된_모임에서는_승인이_눌리지_않는다() async {
        let store = TestStore(initialState: loadedState(isEnded: true)) {
            MemberManagementFeature()
        }
        XCTAssertFalse(store.state.canApprove(MeetingDetailFixtures.member(2, status: .pending)))
        await store.send(.approveTapped(userID: "user-2"))
    }

    func test_종료된_모임에서는_내보내기가_눌리지_않는다() async {
        let store = TestStore(initialState: loadedState(isEnded: true)) {
            MemberManagementFeature()
        }
        await store.send(.kickTapped(userID: "user-1"))
    }

    func test_종료된_모임에서는_승인과_내보내기_버튼을_보이지_않는다() {
        XCTAssertFalse(loadedState(isEnded: true).showsMemberActions)
        XCTAssertTrue(loadedState(isEnded: false).showsMemberActions)
    }

    func test_내보내기는_확인_창을_띄우고_확인하면_내보내고_흐름에_올린다() async {
        let store = TestStore(initialState: loadedState()) {
            MemberManagementFeature()
        } withDependencies: {
            $0.meetingClient.kick = { _, userID in
                XCTAssertEqual(userID, "user-1")
            }
        }

        await store.send(.kickTapped(userID: "user-1")) {
            $0.kickTarget = MeetingDetailFixtures.member(1)
        }
        await store.send(.kickConfirmed) {
            $0.kickTarget = nil
            $0.requestingUserIDs = ["user-1"]
        }
        await store.receive(.kicked(userID: "user-1")) {
            $0.requestingUserIDs = []
            $0.members = []
        }
        await store.receive(.delegate(.memberKicked(userID: "user-1")))
    }

    func test_내보내기_확인_창을_닫으면_내보내지_않는다() async {
        let store = TestStore(initialState: loadedState()) {
            MemberManagementFeature()
        }
        await store.send(.kickTapped(userID: "user-1")) {
            $0.kickTarget = MeetingDetailFixtures.member(1)
        }
        await store.send(.kickDismissed) {
            $0.kickTarget = nil
        }
    }

    func test_모임장은_내보낼_수_없다() async {
        let store = TestStore(initialState: loadedState()) {
            MemberManagementFeature()
        }
        await store.send(.kickTapped(userID: MeetingDetailFixtures.hostID))
    }

    func test_내보내기가_실패하면_멤버에_남고_오류를_띄운다() async {
        var state = loadedState()
        state.kickTarget = MeetingDetailFixtures.member(1)
        let store = TestStore(initialState: state) {
            MemberManagementFeature()
        } withDependencies: {
            $0.meetingClient.kick = { _, _ in throw MeetingError.unknown(message: "") }
        }

        await store.send(.kickConfirmed) {
            $0.kickTarget = nil
            $0.requestingUserIDs = ["user-1"]
        }
        await store.receive(.kickFailed(userID: "user-1", .unknown(message: ""))) {
            $0.requestingUserIDs = []
            $0.screen = .actionFailed(message: "내보내지 못했어요")
        }
    }

    func test_탭을_고르고_X를_누르면_흐름에_닫기를_올린다() async {
        let store = TestStore(initialState: loadedState()) {
            MemberManagementFeature()
        }
        XCTAssertEqual(MemberManagementFeature.Tab.allCases.map(\.title), ["멤버", "승인 대기", "알림 요청"])
        await store.send(.tabSelected(.pending)) {
            $0.tab = .pending
        }
        await store.send(.closeTapped)
        await store.receive(.delegate(.closeRequested))
    }
}

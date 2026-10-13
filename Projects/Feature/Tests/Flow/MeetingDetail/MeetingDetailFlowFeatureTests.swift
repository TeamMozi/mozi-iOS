import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

@MainActor
final class MeetingDetailFlowFeatureTests: XCTestCase {
    private func hostState(snapPoints: [SnapPoint] = []) async throws -> MeetingDetailFlowFeature.State {
        var state = MeetingDetailFlowFeature.State(detailOf: MeetingDetailFixtures.meetingID)
        state.detail?.meeting = try await MeetingDetailFixtures.meeting(.host)
        state.detail?.members = [MeetingDetailFixtures.member(1)]
        state.detail?.snapPoints = snapPoints
        return state
    }

    /// 사이드바를 띄운 상태로 TestStore 를 만든다.
    private func storeWithSidebar() async throws -> TestStoreOf<MeetingDetailFlowFeature> {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        var state = try await hostState()
        state.management = MeetingManagementFeature.State(meeting: meeting, snapPointCount: 0)
        return TestStore(initialState: state) {
            MeetingDetailFlowFeature()
        }
    }

    func test_상세에서_뒤로_가면_띄운_쪽에_닫기를_올린다() async throws {
        let state = try await hostState()
        let store = TestStore(initialState: state) {
            MeetingDetailFlowFeature()
        }
        await store.send(.detail(.delegate(.closeRequested)))
        await store.receive(.delegate(.dismissRequested))
    }

    func test_모임장_메뉴는_스냅포인트_수와_함께_사이드바를_상세_위에_덮어_띄운다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let snapPoints = [MeetingDetailFixtures.snapPoint(1), MeetingDetailFixtures.snapPoint(2)]
        let state = try await hostState(snapPoints: snapPoints)
        let store = TestStore(initialState: state) {
            MeetingDetailFlowFeature()
        }

        await store.send(.detail(.delegate(.managementRequested))) {
            $0.management = MeetingManagementFeature.State(meeting: meeting, snapPointCount: 2)
        }
        XCTAssertTrue(store.state.path.isEmpty, "사이드바는 흐름의 쌓기에 넣지 않는다")
    }

    func test_사이드바_안에_멤버_관리와_스냅포인트_설정을_쌓고_X와_뒤로로_하나씩_빠진다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let store = try await storeWithSidebar()

        await store.send(.management(.presented(.delegate(.memberManagementRequested)))) {
            $0.managementPath[id: 0] = .memberManagement(
                MemberManagementFeature.State(meetingID: meeting.id, host: meeting.host, isEnded: false)
            )
        }
        await store.send(.managementPath(.element(id: 0, action: .memberManagement(.delegate(.closeRequested))))) {
            $0.managementPath.pop(from: 0)
        }
        await store.send(.management(.presented(.delegate(.snapPointSettingRequested)))) {
            $0.managementPath[id: 1] = .snapPointSetting(
                SnapPointSettingFeature.State(meetingID: meeting.id, isEnded: false)
            )
        }
        await store.send(.managementPath(.popFrom(id: 1))) {
            $0.managementPath.pop(from: 1)
        }
        XCTAssertNotNil(store.state.management, "멤버 관리·스냅 포인트 설정이 빠지면 사이드바로 돌아간다")
        XCTAssertTrue(store.state.path.isEmpty)
    }

    func test_사이드바_X는_덮개와_덮개_안_쌓기를_함께_닫는다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let store = try await storeWithSidebar()

        await store.send(.management(.presented(.delegate(.memberManagementRequested)))) {
            $0.managementPath[id: 0] = .memberManagement(
                MemberManagementFeature.State(meetingID: meeting.id, host: meeting.host, isEnded: false)
            )
        }
        await store.send(.management(.presented(.delegate(.closeRequested)))) {
            $0.management = nil
            $0.managementPath.removeAll()
        }
    }

    func test_모임_관리에서_종료하면_상세와_쌓인_화면이_종료를_안다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let ended = try await MeetingDetailFixtures.meeting(.host, status: .ended)
        let store = try await storeWithSidebar()
        await store.send(.management(.presented(.delegate(.memberManagementRequested)))) {
            $0.managementPath[id: 0] = .memberManagement(
                MemberManagementFeature.State(meetingID: meeting.id, host: meeting.host, isEnded: false)
            )
        }
        await store.send(.management(.presented(.delegate(.snapPointSettingRequested)))) {
            $0.managementPath[id: 1] = .snapPointSetting(
                SnapPointSettingFeature.State(meetingID: meeting.id, isEnded: false)
            )
        }

        await store.send(.management(.presented(.delegate(.meetingChanged(ended))))) {
            $0.detail?.meeting = ended
            $0.management?.meeting = ended
            $0.managementPath[id: 0, case: \.memberManagement]?.isEnded = true
            $0.managementPath[id: 1, case: \.snapPointSetting]?.isEnded = true
        }
    }

    func test_멤버를_승인하면_상세의_참여_인원과_멤버와_사이드바의_인원이_맞춰진다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let store = try await storeWithSidebar()
        await store.send(.management(.presented(.delegate(.memberManagementRequested)))) {
            $0.managementPath[id: 0] = .memberManagement(
                MemberManagementFeature.State(meetingID: meeting.id, host: meeting.host, isEnded: false)
            )
        }

        let approved = MeetingDetailFixtures.member(2)
        let approve = MemberManagementFeature.Action.delegate(.memberApproved(approved))
        await store.send(.managementPath(.element(id: 0, action: .memberManagement(approve)))) {
            $0.detail?.meeting?.joinedCount = 6
            $0.detail?.members = [MeetingDetailFixtures.member(1), approved]
            $0.management?.meeting.joinedCount = 6
        }
        let kick = MemberManagementFeature.Action.delegate(.memberKicked(userID: "user-1"))
        await store.send(.managementPath(.element(id: 0, action: .memberManagement(kick)))) {
            $0.detail?.meeting?.joinedCount = 5
            $0.detail?.members = [approved]
            $0.management?.meeting.joinedCount = 5
        }
    }

    func test_스냅포인트가_바뀌면_상세와_사이드바의_개수가_맞춰진다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let store = try await storeWithSidebar()
        await store.send(.management(.presented(.delegate(.snapPointSettingRequested)))) {
            $0.managementPath[id: 0] = .snapPointSetting(
                SnapPointSettingFeature.State(meetingID: meeting.id, isEnded: false)
            )
        }

        let snapPoints = [MeetingDetailFixtures.snapPoint(1)]
        let changed = SnapPointSettingFeature.Action.delegate(.snapPointsChanged(snapPoints))
        await store.send(.managementPath(.element(id: 0, action: .snapPointSetting(changed)))) {
            $0.detail?.snapPoints = snapPoints
            $0.management?.snapPointCount = 1
        }
    }

    func test_모임을_지우거나_시안_없는_칸을_누르면_흐름_밖으로_올린다() async throws {
        let store = try await storeWithSidebar()

        await store.send(.management(.presented(.delegate(.rowRequested(.joinQuestions)))))
        await store.receive(.delegate(.managementRowRequested(.joinQuestions)))
        let meetingID = MeetingDetailFixtures.meetingID
        await store.send(.management(.presented(.delegate(.meetingDeleted(meetingID: meetingID)))))
        await store.receive(.delegate(.meetingDeleted(meetingID: meetingID)))
    }

    func test_상세의_채팅_필름_시리즈는_흐름_밖으로_올린다() async throws {
        let id = MeetingDetailFixtures.meetingID
        let state = try await hostState()
        let store = TestStore(initialState: state) {
            MeetingDetailFlowFeature()
        }
        await store.send(.detail(.delegate(.chatRequested(meetingID: id))))
        await store.receive(.delegate(.chatRequested(meetingID: id)))
        await store.send(.detail(.delegate(.filmRequested(meetingID: id))))
        await store.receive(.delegate(.filmRequested(meetingID: id)))
        await store.send(.detail(.delegate(.seriesRequested(seriesID: "series-1"))))
        await store.receive(.delegate(.seriesRequested(seriesID: "series-1")))
    }

    func test_위젯으로_시작하면_흐름의_쌓기에_멤버_관리와_스냅포인트_설정을_쌓고_바뀐_값을_위젯에_맞춘다() async throws {
        let meeting = try await MeetingDetailFixtures.meeting(.host)
        let ended = try await MeetingDetailFixtures.meeting(.host, status: .ended)
        var state = MeetingDetailFlowFeature.State(widgetOf: meeting.id)
        state.widget?.meeting = meeting
        let store = TestStore(initialState: state) {
            MeetingDetailFlowFeature()
        }

        await store.send(.widget(.delegate(.memberManagementRequested))) {
            $0.path[id: 0] = .memberManagement(
                MemberManagementFeature.State(meetingID: meeting.id, host: meeting.host, isEnded: false)
            )
        }
        let approved = MeetingDetailFixtures.member(2)
        let approve = MemberManagementFeature.Action.delegate(.memberApproved(approved))
        await store.send(.path(.element(id: 0, action: .memberManagement(approve)))) {
            $0.widget?.meeting?.joinedCount = 6
            $0.widget?.members = [approved]
        }
        await store.send(.path(.element(id: 0, action: .memberManagement(.delegate(.closeRequested))))) {
            $0.path.pop(from: 0)
        }
        await store.send(.widget(.delegate(.snapPointSettingRequested))) {
            $0.path[id: 1] = .snapPointSetting(SnapPointSettingFeature.State(meetingID: meeting.id, isEnded: false))
        }
        let snapPoints = [MeetingDetailFixtures.snapPoint(1)]
        let changed = SnapPointSettingFeature.Action.delegate(.snapPointsChanged(snapPoints))
        await store.send(.path(.element(id: 1, action: .snapPointSetting(changed)))) {
            $0.widget?.snapPoints = snapPoints
        }
        await store.send(.widget(.delegate(.meetingChanged(ended)))) {
            $0.widget?.meeting = ended
            $0.path[id: 1, case: \.snapPointSetting]?.isEnded = true
        }
        await store.send(.widget(.delegate(.closeRequested)))
        await store.receive(.delegate(.dismissRequested))
        XCTAssertNil(store.state.management)
    }
}

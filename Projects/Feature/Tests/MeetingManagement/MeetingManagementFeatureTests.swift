import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

@MainActor
final class MeetingManagementFeatureTests: XCTestCase {
    private func makeStore(
        status: MeetingStatus = .recruiting,
        joinedCount: Int = 5,
        dependencies: @escaping (inout DependencyValues) -> Void = { _ in }
    ) async throws -> TestStoreOf<MeetingManagementFeature> {
        let meeting = try await MeetingDetailFixtures.meeting(.host, status: status, joinedCount: joinedCount)
        return TestStore(initialState: MeetingManagementFeature.State(meeting: meeting, snapPointCount: 6)) {
            MeetingManagementFeature()
        } withDependencies: {
            dependencies(&$0)
        }
    }

    func test_같은_상태를_고르면_아무_일도_없다() async throws {
        let store = try await makeStore()
        await store.send(.statusSelected(.recruiting))
    }

    func test_모집_마감을_고르면_마감하고_바뀐_모임을_올린다() async throws {
        let closed = try await MeetingDetailFixtures.meeting(.host, status: .closed)
        let store = try await makeStore {
            $0.meetingClient.closeRecruitment = { id in
                XCTAssertEqual(id, MeetingDetailFixtures.meetingID)
                return closed
            }
        }

        await store.send(.statusSelected(.closed)) {
            $0.isRequesting = true
        }
        await store.receive(.statusChanged(.closed, .success(closed))) {
            $0.isRequesting = false
            $0.meeting = closed
        }
        await store.receive(.delegate(.meetingChanged(closed)))
    }

    func test_모집_마감된_모임을_모집_중으로_고르면_재개한다() async throws {
        let reopened = try await MeetingDetailFixtures.meeting(.host, status: .recruiting)
        let store = try await makeStore(status: .closed) {
            $0.meetingClient.reopenRecruitment = { _ in reopened }
        }

        await store.send(.statusSelected(.recruiting)) {
            $0.isRequesting = true
        }
        await store.receive(.statusChanged(.recruiting, .success(reopened))) {
            $0.isRequesting = false
            $0.meeting = reopened
        }
        await store.receive(.delegate(.meetingChanged(reopened)))
    }

    func test_정원이_찬_모임을_모집_재개하면_묻지_않고_오류를_띄운다() async throws {
        // reopenRecruitment 를 채우지 않는다. 부르면 테스트가 깨진다.
        let store = try await makeStore(status: .closed, joinedCount: 8)
        await store.send(.statusSelected(.recruiting)) {
            $0.screen = .actionFailed(message: "정원이 다 차서 모집을 다시 열 수 없어요")
        }
    }

    func test_서버가_빈_충돌로_재개를_막으면_정원_문구를_띄운다() async throws {
        let store = try await makeStore(status: .closed) {
            $0.meetingClient.reopenRecruitment = { _ in throw MeetingError.conflict(message: "") }
        }

        await store.send(.statusSelected(.recruiting)) {
            $0.isRequesting = true
        }
        await store.receive(.statusChanged(.recruiting, .failure(.conflict(message: "")))) {
            $0.isRequesting = false
            $0.screen = .actionFailed(message: "정원이 다 차서 모집을 다시 열 수 없어요")
        }
    }

    func test_마감이_실패하면_서버_문구가_없을_때_동작_문구를_띄운다() async throws {
        let store = try await makeStore {
            $0.meetingClient.closeRecruitment = { _ in throw MeetingError.unknown(message: "") }
        }

        await store.send(.statusSelected(.closed)) {
            $0.isRequesting = true
        }
        await store.receive(.statusChanged(.closed, .failure(.unknown(message: "")))) {
            $0.isRequesting = false
            $0.screen = .actionFailed(message: "모집을 마감하지 못했어요")
        }
    }

    func test_상태_칩_항목은_모집_중이면_종료를_빼고_모집_마감이면_셋이다() {
        XCTAssertEqual(MeetingManagementFeature.selectableStatuses(from: .recruiting), [.recruiting, .closed])
        XCTAssertEqual(MeetingManagementFeature.selectableStatuses(from: .closed), [.recruiting, .closed, .ended])
        XCTAssertEqual(MeetingManagementFeature.selectableStatuses(from: .ended), [.recruiting, .closed, .ended])
    }

    func test_모집_중에서_종료를_고르면_확인_창도_요청도_없다() async throws {
        // end 를 채우지 않는다. 부르면 테스트가 깨진다.
        let store = try await makeStore()
        await store.send(.statusSelected(.ended))
    }

    func test_모집_마감에서_종료를_고르면_확인_창을_띄우고_확인하면_종료한다() async throws {
        let ended = try await MeetingDetailFixtures.meeting(.host, status: .ended)
        let store = try await makeStore(status: .closed) {
            $0.meetingClient.end = { _ in ended }
        }

        await store.send(.statusSelected(.ended)) {
            $0.confirmation = .endMeeting
        }
        await store.send(.confirmationConfirmed) {
            $0.confirmation = nil
            $0.isRequesting = true
        }
        await store.receive(.statusChanged(.ended, .success(ended))) {
            $0.isRequesting = false
            $0.meeting = ended
        }
        await store.receive(.delegate(.meetingChanged(ended)))
        XCTAssertTrue(store.state.isEnded)
    }

    func test_종료_확인_창을_닫으면_종료하지_않는다() async throws {
        let store = try await makeStore(status: .closed)
        await store.send(.statusSelected(.ended)) {
            $0.confirmation = .endMeeting
        }
        await store.send(.confirmationDismissed) {
            $0.confirmation = nil
        }
    }

    func test_종료된_모임은_상태_칩을_골라도_아무_일도_없다() async throws {
        let store = try await makeStore(status: .ended)
        await store.send(.statusSelected(.recruiting))
        await store.send(.statusSelected(.closed))
    }

    func test_모임_삭제는_확인_뒤_지우고_흐름에_끝을_올린다() async throws {
        let store = try await makeStore {
            $0.meetingClient.delete = { id in
                XCTAssertEqual(id, MeetingDetailFixtures.meetingID)
            }
        }

        await store.send(.deleteTapped) {
            $0.confirmation = .deleteMeeting
        }
        await store.send(.confirmationConfirmed) {
            $0.confirmation = nil
            $0.isRequesting = true
        }
        await store.receive(.deleteSucceeded) {
            $0.isRequesting = false
        }
        await store.receive(.delegate(.meetingDeleted(meetingID: MeetingDetailFixtures.meetingID)))
    }

    func test_삭제가_실패하면_오류를_띄운다() async throws {
        let store = try await makeStore {
            $0.meetingClient.delete = { _ in throw MeetingError.network }
        }

        await store.send(.deleteTapped) {
            $0.confirmation = .deleteMeeting
        }
        await store.send(.confirmationConfirmed) {
            $0.confirmation = nil
            $0.isRequesting = true
        }
        await store.receive(.deleteFailed(.network)) {
            $0.isRequesting = false
            $0.screen = .actionFailed(message: "네트워크 연결을 확인해 주세요")
        }
    }

    func test_닫기와_멤버_관리와_스냅포인트_설정과_다섯_칸은_delegate로_올린다() async throws {
        let store = try await makeStore()
        await store.send(.closeTapped)
        await store.receive(.delegate(.closeRequested))
        await store.send(.memberManagementTapped)
        await store.receive(.delegate(.memberManagementRequested))
        await store.send(.snapPointSettingTapped)
        await store.receive(.delegate(.snapPointSettingRequested))
        for row in [MeetingManagementFeature.Row.posterEdit, .infoEdit, .joinQuestions, .joinType, .capacity] {
            await store.send(.rowTapped(row))
            await store.receive(.delegate(.rowRequested(row)))
        }
    }
}

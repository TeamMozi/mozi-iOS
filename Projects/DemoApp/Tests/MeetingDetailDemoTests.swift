import Domain
import Feature
import Foundation
@testable import MoziDemoKit
import ThirdParty
import XCTest

final class MeetingDetailDemoTests: XCTestCase {
    func test_관점_넷과_위젯_상태_둘의_이름() {
        XCTAssertEqual(MeetingDetailDemoState.allCases.map(\.title), ["모임장", "멤버", "승인 대기", "신청 전"])
        XCTAssertEqual(MeetingDetailDemoState.allCases.map(\.shortTitle), ["모임장", "멤버", "대기", "신청 전"])
        XCTAssertEqual(MeetingWidgetDemoState.allCases.map(\.title), ["알림 전", "진행 중"])
        XCTAssertEqual(MeetingWidgetDemoState.allCases.map(\.sentSnapPointCount), [0, 2])
    }

    func test_신청_전에_신청하면_승인_대기가_되고_모임장이_승인하면_멤버가_된다() async throws {
        let backend = MeetingDetailDemoBackend()
        let before = try await backend.meeting(as: .applicant)
        XCTAssertEqual(before.myParticipation, MyParticipation.none)

        let joined = try await backend.join(as: .applicant)
        XCTAssertEqual(joined, .pending)
        let afterJoin = try await backend.meeting(as: .applicant)
        XCTAssertEqual(afterJoin.myParticipation, .pending)

        let host = try await backend.meeting(as: .host)
        XCTAssertEqual(host.myParticipation, .host)
        let pending = try await backend.members(status: .pending)
        XCTAssertTrue(pending.contains { $0.userID == MeetingDetailDemoBackend.viewerID })

        try await backend.approve(userID: MeetingDetailDemoBackend.viewerID)
        let members = try await backend.members(status: .joined)
        XCTAssertTrue(members.contains { $0.userID == MeetingDetailDemoBackend.viewerID })
        let afterApprove = try await backend.meeting(as: .host)
        XCTAssertEqual(afterApprove.joinedCount, host.joinedCount + 1)
    }

    func test_멤버_관점에서_나가면_신청_전이_되고_참여_인원이_돌아온다() async throws {
        let backend = MeetingDetailDemoBackend()
        let host = try await backend.meeting(as: .host)
        let member = try await backend.meeting(as: .member)
        XCTAssertEqual(member.myParticipation, .member)
        XCTAssertEqual(member.joinedCount, host.joinedCount + 1)

        try await backend.leave(as: .member)
        let left = try await backend.meeting(as: .member)
        XCTAssertEqual(left.myParticipation, MyParticipation.none)
        XCTAssertEqual(left.joinedCount, host.joinedCount)
    }

    func test_정원이_차면_승인과_모집_재개가_conflict() async throws {
        let backend = MeetingDetailDemoBackend(capacity: 5)
        _ = try await backend.meeting(as: .host)
        let pending = try await backend.members(status: .pending)
        let userID = try XCTUnwrap(pending.first?.userID)
        do {
            try await backend.approve(userID: userID)
            XCTFail("conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
        _ = try await backend.changeStatus(to: .closed)
        do {
            _ = try await backend.changeStatus(to: .recruiting)
            XCTFail("conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
    }

    func test_내보내면_멤버에서_빠지고_참여_인원이_준다() async throws {
        let backend = MeetingDetailDemoBackend()
        let host = try await backend.meeting(as: .host)
        let joined = try await backend.members(status: .joined)
        let userID = try XCTUnwrap(joined.first?.userID)

        try await backend.kick(userID: userID)
        let after = try await backend.members(status: .joined)
        XCTAssertFalse(after.contains { $0.userID == userID })
        let meeting = try await backend.meeting(as: .host)
        XCTAssertEqual(meeting.joinedCount, host.joinedCount - 1)
    }

    func test_모집_중에서_바로_종료하면_conflict이고_모집_마감을_거치면_종료한다() async throws {
        let backend = MeetingDetailDemoBackend()
        let recruiting = try await backend.meeting(as: .host)
        XCTAssertEqual(recruiting.status, .recruiting)
        do {
            _ = try await backend.changeStatus(to: .ended)
            XCTFail("conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
        _ = try await backend.changeStatus(to: .closed)
        let ended = try await backend.changeStatus(to: .ended)
        XCTAssertEqual(ended.status, .ended)
    }

    func test_종료하면_상태를_되돌리지_않고_스냅포인트를_바꾸지_않는다() async throws {
        let backend = MeetingDetailDemoBackend()
        _ = try await backend.changeStatus(to: .closed)
        let ended = try await backend.changeStatus(to: .ended)
        XCTAssertEqual(ended.status, .ended)
        do {
            _ = try await backend.changeStatus(to: .closed)
            XCTFail("conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
        do {
            _ = try await backend.addSnapPoint(SnapPointDraft(name: "단체 사진", notificationMessage: ""))
            XCTFail("meetingEnded 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? SnapPointError, .meetingEnded)
        }
    }

    func test_스냅포인트는_열개까지_더하고_넘으면_limitExceeded() async throws {
        let backend = MeetingDetailDemoBackend()
        let seeded = try await backend.allSnapPoints()
        XCTAssertEqual(seeded.count, 6)
        for number in 7...10 {
            let added = try await backend.addSnapPoint(SnapPointDraft(name: "스냅 \(number)", notificationMessage: ""))
            XCTAssertEqual(added.order, number)
        }
        do {
            _ = try await backend.addSnapPoint(SnapPointDraft(name: "스냅 11", notificationMessage: ""))
            XCTFail("limitExceeded 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? SnapPointError, .limitExceeded)
        }
    }

    func test_알림을_보내면_지금_시각과_참여수가_차고_보낸_것은_지우지_않는다() async throws {
        let now = Date(timeIntervalSince1970: 1_784_180_400)
        let backend = MeetingDetailDemoBackend(now: { now })
        let snapPoints = try await backend.allSnapPoints()
        let id = try XCTUnwrap(snapPoints.last?.id)

        let sent = try await backend.sendNotification(id: id)
        XCTAssertEqual(sent.sentAt, now)
        XCTAssertNotNil(sent.participantCount)
        do {
            try await backend.deleteSnapPoint(id: id)
            XCTFail("sentSnapPointNotDeletable 을 던져야 한다")
        } catch {
            XCTAssertEqual(error as? SnapPointError, .sentSnapPointNotDeletable)
        }
    }

    func test_위젯_진행_중은_앞의_둘을_보낸_채로_시작한다() async throws {
        let sentCount = MeetingWidgetDemoState.inProgress.sentSnapPointCount
        let backend = MeetingDetailDemoBackend(sentSnapPointCount: sentCount)
        let snapPoints = try await backend.allSnapPoints()
        XCTAssertEqual(snapPoints.map(\.isSent), [true, true, false, false, false, false])
    }

    func test_위젯_데모는_두_상태_모두_모집_마감으로_시작한다() async throws {
        for state in MeetingWidgetDemoState.allCases {
            let backend = MeetingDetailDemoBackend(
                sentSnapPointCount: state.sentSnapPointCount,
                initialStatus: state.initialMeetingStatus
            )
            let meeting = try await backend.meeting(as: .host)
            XCTAssertEqual(meeting.status, .closed, "\(state.title)")
            XCTAssertTrue(meeting.status.canEnd, "\(state.title)")
        }
    }

    func test_시작_상태를_넘기지_않으면_모집_중으로_시작한다() async throws {
        let backend = MeetingDetailDemoBackend()
        let meeting = try await backend.meeting(as: .host)
        XCTAssertEqual(meeting.status, .recruiting)
    }

    func test_사진을_넘기면_포스터와_모임장_멤버_알림_요청자_나의_사진이_모두_그_사진이다() async throws {
        let photoURL = URL(fileURLWithPath: "/demo/demo_photo.png")
        let backend = MeetingDetailDemoBackend(photoURL: photoURL)

        let meeting = try await backend.meeting(as: .member)
        XCTAssertEqual(meeting.posterURL, photoURL)
        XCTAssertEqual(meeting.host.profileImageURL, photoURL)

        let members = try await backend.members(status: nil)
        XCTAssertTrue(members.contains { $0.userID == MeetingDetailDemoBackend.viewerID })
        XCTAssertEqual(Set(members.map(\.profileImageURL)), [photoURL])
        let requesters = try await backend.allRequesters()
        XCTAssertFalse(requesters.isEmpty)
        XCTAssertEqual(Set(requesters.map(\.profileImageURL)), [photoURL])
    }

    func test_사진을_넘기지_않으면_Domain_가짜_데이터처럼_사진이_없다() async throws {
        let backend = MeetingDetailDemoBackend()
        let meeting = try await backend.meeting(as: .member)
        XCTAssertNil(meeting.posterURL)
        XCTAssertNil(meeting.host.profileImageURL)
        let members = try await backend.members(status: nil)
        XCTAssertTrue(members.allSatisfy { $0.profileImageURL == nil })
    }

    func test_사진을_넘긴_시리즈_Client_는_회차_카드의_포스터와_모임장_사진을_바꾼다() async throws {
        let photoURL = URL(fileURLWithPath: "/demo/demo_photo.png")
        let client = MeetingDetailDemoClients.seriesClient(photoURL: photoURL)
        let page = try await client.episodes(SeriesClient.PreviewID.sample, .first)
        XCTAssertFalse(page.items.isEmpty)
        XCTAssertTrue(page.items.allSatisfy { $0.posterURL == photoURL && $0.host.profileImageURL == photoURL })
    }
}

@MainActor
final class DemoMeetingDetailFeatureTests: XCTestCase {
    func test_흐름이_닫기를_올리면_데모_화면을_나간다() async {
        let store = TestStore(
            initialState: DemoMeetingDetailFeature.State(
                flow: MeetingDetailFlowFeature.State(detailOf: MeetingDetailDemoBackend.meetingID)
            )
        ) {
            DemoMeetingDetailFeature()
        }

        await store.send(.flow(.delegate(.dismissRequested))) {
            $0.isFinished = true
        }
    }

    func test_흐름이_모임_삭제를_올리면_데모_화면을_나간다() async {
        let store = TestStore(
            initialState: DemoMeetingDetailFeature.State(
                flow: MeetingDetailFlowFeature.State(detailOf: MeetingDetailDemoBackend.meetingID)
            )
        ) {
            DemoMeetingDetailFeature()
        }

        await store.send(.flow(.delegate(.meetingDeleted(meetingID: MeetingDetailDemoBackend.meetingID)))) {
            $0.isFinished = true
        }
    }
}

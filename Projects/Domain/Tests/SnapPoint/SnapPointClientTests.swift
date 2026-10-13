import Domain
import XCTest

final class SnapPointClientTests: XCTestCase {
    private let host = MeetingClient.PreviewID.host

    func test_previewValue_모임장_모임은_여섯을_추가한_순서로_돌려주고_앞의_둘은_보냈다() async throws {
        let snapPoints = try await SnapPointClient.previewValue.snapPoints(meetingID: host)
        XCTAssertEqual(snapPoints.map(\.order), [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(snapPoints.map(\.isSent), [true, true, false, false, false, false])
        XCTAssertNotNil(snapPoints[0].participantCount)
        XCTAssertNil(snapPoints[2].participantCount)
    }

    func test_previewValue_다른_모임은_스냅포인트가_없다() async throws {
        let snapPoints = try await SnapPointClient.previewValue.snapPoints(meetingID: MeetingClient.PreviewID.none)
        XCTAssertTrue(snapPoints.isEmpty)
    }

    func test_previewValue_추가하면_다음_순서의_보내지_않은_스냅포인트를_돌려준다() async throws {
        let draft = SnapPointDraft(name: "단체 사진", notificationMessage: "다 같이 모여요")
        let added = try await SnapPointClient.previewValue.add(meetingID: host, draft: draft)
        XCTAssertEqual(added.name, draft.name)
        XCTAssertEqual(added.notificationMessage, draft.notificationMessage)
        XCTAssertEqual(added.order, 7)
        XCTAssertFalse(added.isSent)
    }

    func test_previewValue_이름이_공백뿐이거나_알림메시지가_50자를_넘으면_validation() async {
        let drafts = [
            SnapPointDraft(name: "  ", notificationMessage: "안내"),
            SnapPointDraft(name: "단체 사진", notificationMessage: String(repeating: "가", count: 51)),
        ]
        for draft in drafts {
            do {
                _ = try await SnapPointClient.previewValue.add(meetingID: host, draft: draft)
                XCTFail("validation 을 던져야 한다")
            } catch {
                XCTAssertEqual(error as? SnapPointError, .validation(message: ""))
            }
        }
    }

    func test_previewValue_보낸_스냅포인트도_고치면_새_이름과_문구를_돌려준다() async throws {
        let draft = SnapPointDraft(name: "도착 인증", notificationMessage: "도착했나요?")
        let updated = try await SnapPointClient.previewValue.update(
            meetingID: host,
            snapPointID: "preview-snap-point-1",
            draft: draft
        )
        XCTAssertEqual(updated.name, "도착 인증")
        XCTAssertTrue(updated.isSent)
    }

    func test_previewValue_보낸_스냅포인트를_지우면_sentSnapPointNotDeletable() async {
        do {
            try await SnapPointClient.previewValue.delete(meetingID: host, snapPointID: "preview-snap-point-1")
            XCTFail("sentSnapPointNotDeletable 을 던져야 한다")
        } catch {
            XCTAssertEqual(error as? SnapPointError, .sentSnapPointNotDeletable)
        }
    }

    func test_previewValue_보내지_않은_스냅포인트는_지운다() async throws {
        try await SnapPointClient.previewValue.delete(meetingID: host, snapPointID: "preview-snap-point-3")
    }

    func test_previewValue_모르는_스냅포인트를_지우면_notFound() async {
        do {
            try await SnapPointClient.previewValue.delete(meetingID: host, snapPointID: "unknown")
            XCTFail("notFound 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? SnapPointError, .notFound)
        }
    }

    func test_previewValue_알림을_보내면_보낸_시각과_참여수가_찬다() async throws {
        let sent = try await SnapPointClient.previewValue.sendNotification(
            meetingID: host,
            snapPointID: "preview-snap-point-3"
        )
        XCTAssertTrue(sent.isSent)
        XCTAssertNotNil(sent.participantCount)
    }
}

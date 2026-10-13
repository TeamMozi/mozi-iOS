import Domain
import XCTest

final class MeetingStatusChangeTests: XCTestCase {
    func test_previewValue_모집_마감하면_모집마감_상태의_모임을_돌려줌() async throws {
        let meeting = try await MeetingClient.previewValue.closeRecruitment(id: MeetingClient.PreviewID.host)
        XCTAssertEqual(meeting.id, MeetingClient.PreviewID.host)
        XCTAssertEqual(meeting.status, .closed)
    }

    func test_previewValue_정원이_남은_모임을_모집_재개하면_모집중() async throws {
        // 모임장 가짜 모임은 정원 8, 참여 5 다.
        let meeting = try await MeetingClient.previewValue.reopenRecruitment(id: MeetingClient.PreviewID.host)
        XCTAssertEqual(meeting.status, .recruiting)
    }

    func test_previewValue_정원이_찬_모임을_모집_재개하면_conflict() async {
        // 멤버 가짜 모임은 정원 6, 참여 6, 모집 마감이다.
        do {
            _ = try await MeetingClient.previewValue.reopenRecruitment(id: MeetingClient.PreviewID.member)
            XCTFail("conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
    }

    func test_previewValue_모집_마감된_모임을_종료하면_종료_상태() async throws {
        // 멤버 가짜 모임은 모집 마감이다.
        let meeting = try await MeetingClient.previewValue.end(id: MeetingClient.PreviewID.member)
        XCTAssertEqual(meeting.status, .ended)
    }

    func test_previewValue_모집중_모임을_종료하면_conflict() async {
        // 모임장 가짜 모임은 모집 중이다. 서버처럼 모집 마감을 거쳐야 종료한다.
        do {
            _ = try await MeetingClient.previewValue.end(id: MeetingClient.PreviewID.host)
            XCTFail("conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
    }

    func test_previewValue_종료된_모임은_모집_마감도_재개도_conflict() async {
        // 시리즈 walk 의 1회차는 종료된 모임이다.
        let endedID = "preview-meeting-walk-1"
        do {
            _ = try await MeetingClient.previewValue.closeRecruitment(id: endedID)
            XCTFail("마감은 conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
        do {
            _ = try await MeetingClient.previewValue.reopenRecruitment(id: endedID)
            XCTFail("재개는 conflict 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .conflict(message: ""))
        }
    }

    func test_previewValue_모르는_id면_상태_바꾸기는_notFound() async {
        do {
            _ = try await MeetingClient.previewValue.end(id: "unknown")
            XCTFail("notFound 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .notFound)
        }
    }
}

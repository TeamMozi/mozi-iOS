import Domain
import XCTest

final class MeetingClientTests: XCTestCase {
    func test_MeetingClient_testValue는_생성_가능() {
        // testValue 는 MeetingClient.swift 의 TestDependencyKey 확장이 선언한다.
        // @DependencyClient 는 미구현 클로저를 채운 init 을 제공한다.
        _ = MeetingClient.testValue
    }

    func test_MeetingClient_previewValue는_생성_가능() {
        _ = MeetingClient.previewValue
    }

    func test_previewValue_모임_넷이_나의_참여상태_넷을_모두_담음() async throws {
        var participations: Set<MyParticipation> = []
        for id in MeetingClient.PreviewID.all {
            participations.insert(try await MeetingClient.previewValue.meeting(id: id).myParticipation)
        }
        XCTAssertEqual(participations, [.host, .member, .pending, .none])
    }

    func test_previewValue_관점별_id는_그_참여상태의_모임을_돌려줌() async throws {
        let client = MeetingClient.previewValue
        let host = try await client.meeting(id: MeetingClient.PreviewID.host)
        let member = try await client.meeting(id: MeetingClient.PreviewID.member)
        let pending = try await client.meeting(id: MeetingClient.PreviewID.pending)
        let none = try await client.meeting(id: MeetingClient.PreviewID.none)
        XCTAssertEqual(host.myParticipation, .host)
        XCTAssertEqual(member.myParticipation, .member)
        XCTAssertEqual(pending.myParticipation, .pending)
        XCTAssertEqual(none.myParticipation, .none)
    }

    func test_previewValue_가짜_모임은_글자수와_인원_상한을_넘지_않음() async throws {
        for id in MeetingClient.PreviewID.all {
            let meeting = try await MeetingClient.previewValue.meeting(id: id)
            XCTAssertLessThanOrEqual(meeting.title.count, MeetingLimit.titleMaxLength, meeting.title)
            XCTAssertLessThanOrEqual(meeting.intro?.count ?? 0, MeetingLimit.introMaxLength, meeting.title)
            XCTAssertLessThanOrEqual(meeting.detail?.count ?? 0, MeetingLimit.detailMaxLength, meeting.title)
            XCTAssertTrue(MeetingLimit.capacityRange.contains(meeting.capacity), meeting.title)
            XCTAssertLessThanOrEqual(meeting.joinedCount, meeting.capacity, meeting.title)
        }
    }

    func test_previewValue_모르는_id면_notFound() async {
        do {
            _ = try await MeetingClient.previewValue.meeting(id: "unknown")
            XCTFail("notFound 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? MeetingError, .notFound)
        }
    }

    func test_previewValue_승인후가입_모임에_신청하면_승인대기() async throws {
        let participation = try await MeetingClient.previewValue.join(
            id: MeetingClient.PreviewID.none,
            answers: ["주 2회"]
        )
        XCTAssertEqual(participation, .pending)
    }

    func test_previewValue_멤버_상태로_거르면_그_상태만_돌려줌() async throws {
        let pending = try await MeetingClient.previewValue.members(
            id: MeetingClient.PreviewID.host,
            status: .pending
        )
        XCTAssertFalse(pending.isEmpty)
        XCTAssertTrue(pending.allSatisfy { $0.status == .pending })
    }

    func test_previewValue_앵콜은_모임과_시리즈를_함께_돌려줌() async throws {
        let draft = EncoreDraft(
            meeting: MeetingFixtures.draft(),
            previousMeetingID: MeetingClient.PreviewID.member,
            seriesTitle: "한강 필름 산책 시리즈",
            seriesIntro: nil
        )
        let result = try await MeetingClient.previewValue.createEncore(draft: draft)
        guard case let .created(meeting, series) = result else {
            return XCTFail("created 가 와야 한다")
        }
        XCTAssertEqual(meeting.title, draft.meeting.title)
        XCTAssertEqual(meeting.episode?.seriesID, series.id)
        XCTAssertEqual(series.title, draft.seriesTitle)
    }

    func test_불러오기_최신순_첫_요청은_0번_페이지_10개() {
        XCTAssertEqual(MeetingClient.hostedMeetingsFirstPage, PageRequest(page: 0, size: 10))
    }

    func test_previewValue_불러오기_첫_페이지는_10개와_다음_페이지_요청() async throws {
        let page = try await MeetingClient.previewValue.hostedMeetings(page: MeetingClient.hostedMeetingsFirstPage)
        XCTAssertEqual(page.items.count, 10)
        XCTAssertEqual(page.next, PageRequest(page: 1, size: 10))
    }

    func test_previewValue_불러오기_마지막_페이지는_남은_4개와_next_nil() async throws {
        let page = try await MeetingClient.previewValue.hostedMeetings(page: PageRequest(page: 1, size: 10))
        XCTAssertEqual(page.items.count, 4)
        XCTAssertNil(page.next)
    }

    func test_previewValue_불러오기_범위밖_페이지는_빈목록과_next_nil() async throws {
        for request in [PageRequest(page: 2, size: 10), PageRequest(page: Int.max, size: 10)] {
            let page = try await MeetingClient.previewValue.hostedMeetings(page: request)
            XCTAssertTrue(page.items.isEmpty, "\(request)")
            XCTAssertNil(page.next, "\(request)")
        }
    }

    func test_previewValue_불러오기_size가_0이하거나_page가_음수면_빈목록과_next_nil() async throws {
        let requests = [PageRequest(page: 0, size: 0), PageRequest(page: 0, size: -1), PageRequest(page: -1, size: 10)]
        for request in requests {
            let page = try await MeetingClient.previewValue.hostedMeetings(page: request)
            XCTAssertTrue(page.items.isEmpty, "\(request)")
            XCTAssertNil(page.next, "\(request)")
        }
    }

    func test_previewValue_불러오기_next를_따라가면_내가_연_모임을_최신순으로_한번씩_돌려줌() async throws {
        var request: PageRequest? = MeetingClient.hostedMeetingsFirstPage
        var meetings: [Meeting] = []
        var pageCount = 0
        while let current = request, pageCount < 10 {
            let page = try await MeetingClient.previewValue.hostedMeetings(page: current)
            meetings += page.items
            request = page.next
            pageCount += 1
        }
        XCTAssertNil(request, "10 페이지 안에 끝나야 한다")
        XCTAssertEqual(meetings.count, 14)
        XCTAssertEqual(Set(meetings.map(\.id)).count, meetings.count)
        XCTAssertEqual(meetings.map(\.startAt), meetings.map(\.startAt).sorted(by: >))
        for meeting in meetings {
            XCTAssertEqual(meeting.myParticipation, .host, meeting.title)
            XCTAssertLessThanOrEqual(meeting.title.count, MeetingLimit.titleMaxLength, meeting.title)
            XCTAssertLessThanOrEqual(meeting.intro?.count ?? 0, MeetingLimit.introMaxLength, meeting.title)
            XCTAssertTrue(MeetingLimit.capacityRange.contains(meeting.capacity), meeting.title)
            XCTAssertLessThanOrEqual(meeting.joinedCount, meeting.capacity, meeting.title)
            if meeting.status == .ended {
                XCTAssertLessThan(meeting.startAt, Date(), meeting.title)
            } else {
                // 2030-01-01 00:00 UTC 이후
                XCTAssertGreaterThanOrEqual(meeting.startAt, Date(timeIntervalSince1970: 1_893_456_000), meeting.title)
            }
        }
    }

    func test_previewValue_불러온_모임은_id로_다시_읽힘() async throws {
        let page = try await MeetingClient.previewValue.hostedMeetings(page: MeetingClient.hostedMeetingsFirstPage)
        for meeting in page.items {
            let loaded = try await MeetingClient.previewValue.meeting(id: meeting.id)
            XCTAssertEqual(loaded, meeting)
        }
    }

    func test_previewValue_고치기는_초안_값만_바꾸고_회차_상태_인원은_이어받음() async throws {
        let id = "preview-meeting-walk-12"
        let current = try await MeetingClient.previewValue.meeting(id: id)
        let updated = try await MeetingClient.previewValue.update(id: id, draft: MeetingFixtures.draft(seriesID: nil))
        XCTAssertEqual(updated.title, MeetingFixtures.draft().title)
        XCTAssertEqual(updated.episode, current.episode)
        XCTAssertNotNil(updated.episode)
        XCTAssertEqual(updated.status, current.status)
        XCTAssertEqual(updated.joinedCount, current.joinedCount)
    }

    func test_previewValue_멤버_상태가_비어있으면_승인대기까지_모두_돌려줌() async throws {
        let members = try await MeetingClient.previewValue.members(id: MeetingClient.PreviewID.host, status: nil)
        XCTAssertTrue(members.contains { $0.status == .joined })
        XCTAssertTrue(members.contains { $0.status == .pending })
    }

    func test_previewValue_만들기는_초안_값을_담은_모임을_돌려줌() async throws {
        let draft = MeetingFixtures.draft()
        let meeting = try await MeetingClient.previewValue.create(draft: draft)
        XCTAssertEqual(meeting.title, draft.title)
        XCTAssertEqual(meeting.startAt, draft.startAt)
        XCTAssertEqual(meeting.capacity, draft.capacity)
        XCTAssertEqual(meeting.joinType, draft.joinType)
        XCTAssertEqual(meeting.place, draft.place)
        XCTAssertEqual(meeting.category.id, draft.categoryID)
    }
}

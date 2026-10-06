import Foundation
import ThirdParty

/// 모임과 멤버를 다루는 Domain 포트.
@DependencyClient
public struct MeetingClient: Sendable {
    public var create: @Sendable (_ draft: MeetingDraft) async throws -> Meeting
    /// 새 모임을 먼저 만들고 이전 모임과 묶어 시리즈를 만든다. 시리즈만 실패하면 `.meetingOnly` 를 돌려준다.
    public var createEncore: @Sendable (_ draft: EncoreDraft) async throws -> EncoreResult
    public var meeting: @Sendable (_ id: String) async throws -> Meeting
    public var update: @Sendable (_ id: String, _ draft: MeetingDraft) async throws -> Meeting
    public var delete: @Sendable (_ id: String) async throws -> Void
    /// 참여 신청. `answers` 는 가입 질문의 답이다. 바로 가입이면 `.member`, 승인 후 가입이면 `.pending` 이 온다.
    public var join: @Sendable (_ id: String, _ answers: [String]) async throws -> MyParticipation
    public var leave: @Sendable (_ id: String) async throws -> Void
    /// `status` 가 비어 있으면 모든 멤버를 돌려준다.
    public var members: @Sendable (_ id: String, _ status: MemberStatus?) async throws -> [MeetingMember]
    public var approve: @Sendable (_ meetingID: String, _ userID: String) async throws -> Void
    public var kick: @Sendable (_ meetingID: String, _ userID: String) async throws -> Void
    public var requestNotification: @Sendable (_ id: String) async throws -> Void
    public var cancelNotificationRequest: @Sendable (_ id: String) async throws -> Void
    /// 알림을 요청한 사람 목록. 모임장용이다.
    public var notificationRequesters: @Sendable (_ id: String) async throws -> [MeetingMember]
    /// 내가 연 모임을 최신순(시작 시각 내림차순)으로 돌려준다. 이전 모임 불러오기 「최신순」 이다. 서버에 아직 없다.
    /// 첫 요청은 `MeetingClient.hostedMeetingsFirstPage`, 그다음은 받은 `Page.next` 다.
    /// 페이지 사이에서 겹친 항목은 화면이 id 로 거른다.
    public var hostedMeetings: @Sendable (_ page: PageRequest) async throws -> Page<Meeting>
}

extension MeetingClient: TestDependencyKey {
    public static let testValue = MeetingClient()
    public static let previewValue = MeetingClient(
        create: { draft in
            MeetingPreviewData.meeting(from: draft, id: MeetingPreviewData.createdMeetingID)
        },
        createEncore: { draft in
            var meeting = MeetingPreviewData.meeting(from: draft.meeting, id: MeetingPreviewData.createdMeetingID)
            meeting.episode = SeriesEpisode(seriesID: SeriesPreviewData.createdSeriesID, number: 2)
            return .created(meeting, SeriesPreviewData.series(from: draft, meeting: meeting))
        },
        meeting: { id in
            try MeetingPreviewData.meeting(id: id)
        },
        update: { id, draft in
            try MeetingPreviewData.meeting(updating: MeetingPreviewData.meeting(id: id), with: draft)
        },
        delete: { _ in },
        join: { id, _ in
            let meeting = try MeetingPreviewData.meeting(id: id)
            return meeting.joinType == .instant ? .member : .pending
        },
        leave: { _ in },
        members: { _, status in
            MeetingPreviewData.members.filter { member in
                status == nil || member.status == status
            }
        },
        approve: { _, _ in },
        kick: { _, _ in },
        requestNotification: { _ in },
        cancelNotificationRequest: { _ in },
        notificationRequesters: { _ in
            MeetingPreviewData.notificationRequesters
        },
        hostedMeetings: { page in
            Page.slicing(MeetingPreviewData.hostedMeetings, by: page)
        }
    )
}

public extension MeetingClient {
    /// 이전 모임 불러오기 「최신순」 의 첫 요청. 최신 10개다(회의록 10/01).
    static let hostedMeetingsFirstPage = PageRequest(page: 0, size: 10)

    /// `previewValue` 가 아는 모임 id. 나의 참여 상태 넷을 하나씩 담는다.
    enum PreviewID {
        public static let host = "preview-meeting-host"
        public static let member = "preview-meeting-member"
        public static let pending = "preview-meeting-pending"
        public static let none = "preview-meeting-none"
        public static let all = [host, member, pending, none]
    }
}

public extension DependencyValues {
    var meetingClient: MeetingClient {
        get { self[MeetingClient.self] }
        set { self[MeetingClient.self] = newValue }
    }
}

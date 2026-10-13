import Domain
import Foundation

/// 모임 상세 흐름 테스트의 견본. 모임은 Domain 가짜 데이터의 모임장 모임에서 칸을 정해 만든다.
/// `Meeting` 을 직접 만들지 않는다. 함께 도는 작업이 카테고리·배경음악 타입을 바꾸고 있다.
enum MeetingDetailFixtures {
    static let meetingID = "meeting-1"
    /// Domain 가짜 모임장 모임의 모임장 id
    static let hostID = "preview-host"

    static let hostMember = MeetingMember(userID: hostID, nickname: "모지장", profileImageURL: nil, status: .joined)

    static func meeting(
        _ participation: MyParticipation,
        status: MeetingStatus = .recruiting,
        joinType: JoinType = .approval,
        capacity: Int = 8,
        joinedCount: Int = 5,
        joinQuestions: [String] = ["좋아하는 밴드는?"],
        seriesID: String? = nil
    ) async throws -> Meeting {
        var meeting = try await MeetingClient.previewValue.meeting(id: MeetingClient.PreviewID.host)
        meeting.id = meetingID
        meeting.myParticipation = participation
        meeting.status = status
        meeting.joinType = joinType
        meeting.capacity = capacity
        meeting.joinedCount = joinedCount
        meeting.joinQuestions = joinQuestions
        meeting.episode = seriesID.map { SeriesEpisode(seriesID: $0, number: 2) }
        meeting.notificationRequestCount = 4
        meeting.isNotificationRequested = false
        return meeting
    }

    static func member(_ number: Int, status: MemberStatus = .joined) -> MeetingMember {
        MeetingMember(userID: "user-\(number)", nickname: "멤버\(number)", profileImageURL: nil, status: status)
    }

    static func snapPoint(_ number: Int, sentAt: Date? = nil, participantCount: Int? = nil) -> SnapPoint {
        SnapPoint(
            id: "snap-point-\(number)",
            name: "스냅 \(number)",
            notificationMessage: "안내 \(number)",
            order: number,
            sentAt: sentAt,
            participantCount: participantCount
        )
    }

    static func series(id: String = "series-1") -> Series {
        Series(
            id: id,
            title: "걸밴드 오타쿠 모임 시리즈",
            intro: nil,
            coverImageURL: nil,
            host: MeetingHost(
                userID: hostID,
                nickname: "모지장",
                profileImageURL: nil,
                introduction: nil,
                hostedCount: nil,
                participatedCount: nil
            ),
            episodeCount: 34,
            participantCount: 148,
            momentCount: 345,
            recruitingMeetings: [],
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }
}

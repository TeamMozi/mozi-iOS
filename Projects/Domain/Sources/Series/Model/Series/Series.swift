import Foundation

/// 서버에서 읽는 시리즈. 입력은 `SeriesDraft`·`SeriesUpdateDraft` 로 따로 받는다.
public struct Series: Equatable, Sendable {
    public var id: String
    public var title: String
    public var intro: String?
    public var coverImageURL: URL?
    public var host: MeetingHost
    public var episodeCount: Int
    public var participantCount: Int
    /// 모먼트 수. 서버에 아직 없다(명세가 추가를 약속함).
    public var momentCount: Int
    public var recruitingMeetings: [Meeting]
    /// 알림을 요청한 사람 수. 서버에 아직 없다.
    public var notificationRequestCount: Int
    /// 내가 알림을 요청했나. 서버에 아직 없다.
    public var isNotificationRequested: Bool

    public init(
        id: String,
        title: String,
        intro: String?,
        coverImageURL: URL?,
        host: MeetingHost,
        episodeCount: Int,
        participantCount: Int,
        momentCount: Int,
        recruitingMeetings: [Meeting],
        notificationRequestCount: Int,
        isNotificationRequested: Bool
    ) {
        self.id = id
        self.title = title
        self.intro = intro
        self.coverImageURL = coverImageURL
        self.host = host
        self.episodeCount = episodeCount
        self.participantCount = participantCount
        self.momentCount = momentCount
        self.recruitingMeetings = recruitingMeetings
        self.notificationRequestCount = notificationRequestCount
        self.isNotificationRequested = isNotificationRequested
    }
}

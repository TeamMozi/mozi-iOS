import Foundation

/// 서버에서 읽는 모임. 입력은 `MeetingDraft` 로 따로 받는다.
public struct Meeting: Equatable, Sendable {
    public var id: String
    public var title: String
    public var intro: String?
    public var detail: String?
    public var posterURL: URL?
    /// 서버에 아직 없다.
    public var backgroundMusic: BackgroundMusic?
    public var startAt: Date
    public var place: Place
    /// 서버에 아직 없다.
    public var region: Region?
    /// 최대 인원
    public var capacity: Int
    public var joinedCount: Int
    /// 최근 일주일 신청 인원. 서버에 아직 없다. Data 는 0 을 돌려준다.
    public var recentApplicantCount: Int
    public var ageRange: AgeRange
    public var genderRestriction: GenderRestriction
    public var joinType: JoinType
    public var category: Interest
    public var status: MeetingStatus
    public var host: MeetingHost
    /// 시리즈에 묶인 모임이면 몇 회차인지. 묶이지 않았으면 비어 있다.
    public var episode: SeriesEpisode?
    public var myParticipation: MyParticipation
    /// 가입 질문. 서버에 아직 없다.
    public var joinQuestions: [String]
    /// 알림을 요청한 사람 수. 서버에 아직 없다.
    public var notificationRequestCount: Int
    /// 내가 알림을 요청했나. 서버에 아직 없다.
    public var isNotificationRequested: Bool

    public init(
        id: String,
        title: String,
        intro: String?,
        detail: String?,
        posterURL: URL?,
        backgroundMusic: BackgroundMusic?,
        startAt: Date,
        place: Place,
        region: Region?,
        capacity: Int,
        joinedCount: Int,
        recentApplicantCount: Int,
        ageRange: AgeRange,
        genderRestriction: GenderRestriction,
        joinType: JoinType,
        category: Interest,
        status: MeetingStatus,
        host: MeetingHost,
        episode: SeriesEpisode?,
        myParticipation: MyParticipation,
        joinQuestions: [String],
        notificationRequestCount: Int,
        isNotificationRequested: Bool
    ) {
        self.id = id
        self.title = title
        self.intro = intro
        self.detail = detail
        self.posterURL = posterURL
        self.backgroundMusic = backgroundMusic
        self.startAt = startAt
        self.place = place
        self.region = region
        self.capacity = capacity
        self.joinedCount = joinedCount
        self.recentApplicantCount = recentApplicantCount
        self.ageRange = ageRange
        self.genderRestriction = genderRestriction
        self.joinType = joinType
        self.category = category
        self.status = status
        self.host = host
        self.episode = episode
        self.myParticipation = myParticipation
        self.joinQuestions = joinQuestions
        self.notificationRequestCount = notificationRequestCount
        self.isNotificationRequested = isNotificationRequested
    }
}

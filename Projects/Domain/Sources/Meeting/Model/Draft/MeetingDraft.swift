import Foundation

/// 모임 만들기·고치기 입력. 만들기에서 `seriesID` 가 있으면 그 시리즈에 묶는다(3회차부터).
/// 고치기(`update`)는 `seriesID` 를 무시한다. 시리즈 묶기·빼기는 `SeriesClient` 로 한다.
/// 만들기에서 `poster: .keep` 은 포스터 없음과 같다.
public struct MeetingDraft: Equatable, Sendable {
    public var title: String
    public var intro: String?
    public var detail: String?
    public var poster: ImageInput
    public var backgroundMusicID: String?
    public var startAt: Date
    public var place: Place
    /// 최대 인원. `MeetingLimit.capacityRange` 안이어야 한다.
    public var capacity: Int
    public var ageRange: AgeRange
    public var genderRestriction: GenderRestriction
    /// 처음 값은 바로 가입이다(팀 확인 대기).
    public var joinType: JoinType
    public var categoryID: String
    public var seriesID: String?
    public var joinQuestions: [String]

    public init(
        title: String,
        intro: String?,
        detail: String?,
        poster: ImageInput,
        backgroundMusicID: String?,
        startAt: Date,
        place: Place,
        capacity: Int,
        ageRange: AgeRange,
        genderRestriction: GenderRestriction,
        joinType: JoinType = .instant,
        categoryID: String,
        seriesID: String?,
        joinQuestions: [String]
    ) {
        self.title = title
        self.intro = intro
        self.detail = detail
        self.poster = poster
        self.backgroundMusicID = backgroundMusicID
        self.startAt = startAt
        self.place = place
        self.capacity = capacity
        self.ageRange = ageRange
        self.genderRestriction = genderRestriction
        self.joinType = joinType
        self.categoryID = categoryID
        self.seriesID = seriesID
        self.joinQuestions = joinQuestions
    }
}

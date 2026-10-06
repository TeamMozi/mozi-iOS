/// 시리즈 만들기 입력.
public struct SeriesDraft: Equatable, Sendable {
    public var title: String
    public var intro: String?
    /// 묶을 모임 id. 1개 이상이어야 한다.
    public var meetingIDs: [String]

    public init(
        title: String,
        intro: String?,
        meetingIDs: [String]
    ) {
        self.title = title
        self.intro = intro
        self.meetingIDs = meetingIDs
    }
}

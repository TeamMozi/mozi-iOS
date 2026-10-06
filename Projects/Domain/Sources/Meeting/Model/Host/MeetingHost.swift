import Foundation

public struct MeetingHost: Equatable, Sendable {
    public var userID: String
    public var nickname: String
    public var profileImageURL: URL?
    public var introduction: String?
    /// 누적 개최 수. 서버에 아직 없다.
    public var hostedCount: Int?
    /// 누적 참여 수. 서버에 아직 없다.
    public var participatedCount: Int?

    public init(
        userID: String,
        nickname: String,
        profileImageURL: URL?,
        introduction: String?,
        hostedCount: Int?,
        participatedCount: Int?
    ) {
        self.userID = userID
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.introduction = introduction
        self.hostedCount = hostedCount
        self.participatedCount = participatedCount
    }
}

import Foundation

public struct MeetingMember: Equatable, Sendable {
    public var userID: String
    public var nickname: String
    /// 프로필 사진. 서버에 아직 없다.
    public var profileImageURL: URL?
    public var status: MemberStatus

    public init(
        userID: String,
        nickname: String,
        profileImageURL: URL?,
        status: MemberStatus
    ) {
        self.userID = userID
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.status = status
    }
}

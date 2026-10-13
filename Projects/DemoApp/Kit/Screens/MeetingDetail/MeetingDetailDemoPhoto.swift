import Domain
import Foundation

/// 데모 모임에 사진 하나를 돌려 쓴다. Domain 가짜 데이터는 사진이 없어, 받은 값의 사진 URL 만 바꾼다.
/// 사진 파일은 데모 앱 번들 안 `demo_photo.png` 이고, 그 URL 은 앱(`Sources/`)이 찾아 넘긴다.
enum MeetingDetailDemoPhoto {
    /// 모임 포스터와 모임장 프로필 사진을 바꾼다.
    static func applied(_ photoURL: URL, to meeting: Meeting) -> Meeting {
        var meeting = meeting
        meeting.posterURL = photoURL
        meeting.host.profileImageURL = photoURL
        return meeting
    }

    static func applied(_ photoURL: URL, to member: MeetingMember) -> MeetingMember {
        var member = member
        member.profileImageURL = photoURL
        return member
    }
}

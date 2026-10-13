import Foundation

/// 모임 하나에 속한 스냅 포인트. 회차로 이어지지 않는다. 서버에 아직 없다.
public struct SnapPoint: Equatable, Sendable, Identifiable {
    public var id: String
    public var name: String
    /// 촬영 알림 때 멤버에게 보내는 문구. `SnapPointLimit.notificationMessageMaxLength` 자까지다.
    public var notificationMessage: String
    /// 1부터 센다. 추가한 순서다.
    public var order: Int
    /// 촬영 알림을 보낸 시각. 비어 있으면 아직 보내지 않았다.
    public var sentAt: Date?
    /// 알림 뒤 참여한 멤버 수. 보내기 전에는 비어 있다.
    public var participantCount: Int?

    public init(
        id: String,
        name: String,
        notificationMessage: String,
        order: Int,
        sentAt: Date?,
        participantCount: Int?
    ) {
        self.id = id
        self.name = name
        self.notificationMessage = notificationMessage
        self.order = order
        self.sentAt = sentAt
        self.participantCount = participantCount
    }

    public var isSent: Bool {
        sentAt != nil
    }
}

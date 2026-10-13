/// 스냅 포인트 추가·수정 입력.
public struct SnapPointDraft: Equatable, Sendable {
    public var name: String
    public var notificationMessage: String

    public init(name: String, notificationMessage: String) {
        self.name = name
        self.notificationMessage = notificationMessage
    }
}

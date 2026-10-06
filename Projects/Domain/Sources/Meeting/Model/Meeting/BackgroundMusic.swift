/// 포스터 배경음악. 서버에 아직 없다.
public struct BackgroundMusic: Equatable, Sendable {
    public var id: String
    public var title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

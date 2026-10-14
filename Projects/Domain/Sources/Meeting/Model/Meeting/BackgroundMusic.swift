import Foundation

/// 포스터 배경음악. 서버에 아직 없다.
public struct BackgroundMusic: Equatable, Sendable {
    public var id: String
    public var title: String
    /// 앨범 그림. 서버에 아직 없다.
    public var albumImageURL: URL?
    /// 곡 길이(초). 서버에 아직 없다.
    public var durationSeconds: Int
    /// 이 곡을 쓴 포스터 수. 서버에 아직 없다.
    public var useCount: Int

    public init(
        id: String,
        title: String,
        albumImageURL: URL?,
        durationSeconds: Int,
        useCount: Int
    ) {
        self.id = id
        self.title = title
        self.albumImageURL = albumImageURL
        self.durationSeconds = durationSeconds
        self.useCount = useCount
    }
}

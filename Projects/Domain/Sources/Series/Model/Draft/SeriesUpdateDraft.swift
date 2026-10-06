/// 시리즈 고치기 입력.
public struct SeriesUpdateDraft: Equatable, Sendable {
    public var title: String
    public var intro: String?
    public var cover: ImageInput

    public init(
        title: String,
        intro: String?,
        cover: ImageInput
    ) {
        self.title = title
        self.intro = intro
        self.cover = cover
    }
}

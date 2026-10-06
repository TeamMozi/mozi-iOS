/// 모임이 묶인 시리즈와 회차.
public struct SeriesEpisode: Equatable, Sendable {
    public var seriesID: String
    public var number: Int

    public init(seriesID: String, number: Int) {
        self.seriesID = seriesID
        self.number = number
    }
}

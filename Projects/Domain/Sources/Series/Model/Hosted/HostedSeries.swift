import Foundation

/// 내가 연 시리즈와 그 최근 모임. 이전 모임 불러오기 「시리즈별」 목록의 한 칸이다.
/// 나머지 회차는 「더보기」 가 `SeriesClient.episodes` 로 읽는다.
public struct HostedSeries: Equatable, Sendable {
    /// `recentMeetings` 의 최대 개수
    public static let recentMeetingLimit = 3

    public var series: Series
    /// 최근 순(시작 시각 내림차순)이고 `recentMeetingLimit` 개를 넘지 않는다. 자르는 일은 Data 가 한다.
    public var recentMeetings: [Meeting]

    public init(series: Series, recentMeetings: [Meeting]) {
        self.series = series
        self.recentMeetings = recentMeetings
    }
}

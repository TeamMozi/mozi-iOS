import Foundation
import ThirdParty

/// 시리즈를 다루는 Domain 포트. 앵콜로 시리즈를 처음 만드는 일은 `MeetingClient.createEncore` 가 한다.
@DependencyClient
public struct SeriesClient: Sendable {
    public var create: @Sendable (_ draft: SeriesDraft) async throws -> Series
    public var series: @Sendable (_ id: String) async throws -> Series
    public var update: @Sendable (_ id: String, _ draft: SeriesUpdateDraft) async throws -> Series
    public var delete: @Sendable (_ id: String) async throws -> Void
    public var attach: @Sendable (_ seriesID: String, _ meetingID: String) async throws -> Void
    public var detach: @Sendable (_ seriesID: String, _ meetingID: String) async throws -> Void
    public var requestNotification: @Sendable (_ id: String) async throws -> Void
    public var cancelNotificationRequest: @Sendable (_ id: String) async throws -> Void
    /// 시리즈의 회차 모임을 최신 회차부터(시작 시각 내림차순) 돌려준다.
    /// 시리즈 상세는 `PageRequest.first`, 시리즈별 「더보기」 는 `SeriesClient.moreEpisodesFirstPage` 로 시작한다.
    /// 페이지 사이에서 겹친 항목은 화면이 id 로 거른다.
    public var episodes: @Sendable (_ seriesID: String, _ page: PageRequest) async throws -> Page<Meeting>
    /// 내가 연 시리즈와 시리즈마다 최근 모임. 이전 모임 불러오기 「시리즈별」 이다. 서버에 아직 없다.
    /// 첫 요청은 `PageRequest.first`, 그다음은 받은 `Page.next` 다.
    /// 페이지 사이에서 겹친 항목은 화면이 id 로 거른다.
    public var hostedSeries: @Sendable (_ page: PageRequest) async throws -> Page<HostedSeries>
}

extension SeriesClient: TestDependencyKey {
    public static let testValue = SeriesClient()
    public static let previewValue = SeriesClient(
        create: { draft in
            SeriesPreviewData.series(from: draft)
        },
        series: { id in
            try SeriesPreviewData.series(id: id)
        },
        update: { id, draft in
            var series = try SeriesPreviewData.series(id: id)
            series.title = draft.title
            series.intro = draft.intro
            return series
        },
        delete: { _ in },
        attach: { _, _ in },
        detach: { _, _ in },
        requestNotification: { _ in },
        cancelNotificationRequest: { _ in },
        episodes: { seriesID, page in
            try Page.slicing(SeriesPreviewData.episodes(seriesID: seriesID), by: page)
        },
        hostedSeries: { page in
            Page.slicing(SeriesPreviewData.hostedSeries, by: page)
        }
    )
}

public extension SeriesClient {
    /// 이전 모임 불러오기 「시리즈별」 의 「더보기」 첫 요청. `episodes` 를 5개부터 부른다(회의록 10/01).
    /// 이미 보인 `HostedSeries.recentMeetings` 와 겹치는 항목은 화면이 거른다.
    static let moreEpisodesFirstPage = PageRequest(page: 0, size: 5)

    /// `previewValue` 가 아는 시리즈 id. `walk` 는 회차가 여러 페이지를 넘는다.
    enum PreviewID {
        public static let sample = "preview-series"
        public static let walk = "preview-series-walk"
    }
}

public extension DependencyValues {
    var seriesClient: SeriesClient {
        get { self[SeriesClient.self] }
        set { self[SeriesClient.self] = newValue }
    }
}

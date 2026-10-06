import Foundation

/// `SeriesClient.previewValue` 의 가짜 데이터. 글자 수는 `SeriesLimit` 를 넘지 않는다.
enum SeriesPreviewData {
    static let createdSeriesID = "preview-series-created"

    static let sample = Series(
        id: SeriesClient.PreviewID.sample,
        title: "뱅드림 필름 라이브 정주행",
        intro: "매달 한 편씩 필름 라이브를 보고 노래방에서 마무리해요",
        coverImageURL: nil,
        host: MeetingPreviewData.host,
        episodeCount: 2,
        participantCount: 14,
        momentCount: 36,
        recruitingMeetings: [MeetingPreviewData.hostMeeting],
        notificationRequestCount: 8,
        isNotificationRequested: false
    )

    static let walk = Series(
        id: SeriesClient.PreviewID.walk,
        title: "한강 필름 산책 정기 모임",
        intro: "매주 일요일 아침, 한강을 걸으며 한 롤씩 찍어요",
        coverImageURL: nil,
        host: MeetingPreviewData.host,
        episodeCount: MeetingPreviewData.walkEpisodes.count,
        participantCount: 41,
        momentCount: 120,
        recruitingMeetings: [],
        notificationRequestCount: 3,
        isNotificationRequested: false
    )

    /// 내가 연 시리즈. 최근 모임이 더 최근인 시리즈부터.
    static let all = [sample, walk]

    /// `hostedSeries` 가 자르는 목록. 시리즈마다 최근 모임을 `HostedSeries.recentMeetingLimit` 개까지 담는다.
    static let hostedSeries: [HostedSeries] = all.map { series in
        HostedSeries(
            series: series,
            recentMeetings: Array(episodeList(of: series.id).prefix(HostedSeries.recentMeetingLimit))
        )
    }

    static func series(id: String) throws -> Series {
        guard let series = all.first(where: { $0.id == id }) else {
            throw SeriesError.notFound
        }
        return series
    }

    /// 시리즈의 회차 모임. 최신 회차부터(시작 시각 내림차순).
    static func episodes(seriesID: String) throws -> [Meeting] {
        _ = try series(id: seriesID)
        return episodeList(of: seriesID)
    }

    static func series(from draft: SeriesDraft) -> Series {
        Series(
            id: createdSeriesID,
            title: draft.title,
            intro: draft.intro,
            coverImageURL: nil,
            host: MeetingPreviewData.host,
            episodeCount: draft.meetingIDs.count,
            participantCount: 0,
            momentCount: 0,
            recruitingMeetings: MeetingPreviewData.meetings.filter { meeting in
                draft.meetingIDs.contains(meeting.id) && meeting.status == .recruiting
            },
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }

    /// 앵콜로 이전 모임과 새 모임을 묶은 시리즈를 흉내 낸다.
    static func series(from draft: EncoreDraft, meeting: Meeting) -> Series {
        Series(
            id: createdSeriesID,
            title: draft.seriesTitle,
            intro: draft.seriesIntro,
            coverImageURL: nil,
            host: MeetingPreviewData.host,
            episodeCount: 2,
            participantCount: meeting.joinedCount,
            momentCount: 0,
            recruitingMeetings: [meeting],
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }

    // `hostedMeetings` 가 이미 최신순이라 거르기만 해도 최신 회차부터다.
    private static func episodeList(of seriesID: String) -> [Meeting] {
        MeetingPreviewData.hostedMeetings.filter { $0.episode?.seriesID == seriesID }
    }
}

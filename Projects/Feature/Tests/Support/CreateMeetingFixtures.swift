import Domain
import Foundation

/// 모임 만들기 화면 테스트의 견본. 지금은 2026-07-16(목) 09:41(한국 시간)이다.
enum CreateMeetingFixtures {
    /// 2026-07-16 09:41 KST
    static let now = Date(timeIntervalSince1970: 1_784_162_460)

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60) ?? .current
        return calendar
    }

    static let place = Place(
        name: "중앙로 12-3",
        address: "서울 중랑구 중앙로 12-3",
        latitude: 37.6063,
        longitude: 127.0925
    )

    static let host = MeetingHost(
        userID: "host-1",
        nickname: "모지장",
        profileImageURL: nil,
        introduction: nil,
        hostedCount: nil,
        participatedCount: nil
    )

    /// 2026-07-02 19:00 KST 에 끝난, 내가 연 모임.
    static func meeting(id: String = "meeting-1", episode: SeriesEpisode? = nil, posterURL: URL? = nil) -> Meeting {
        Meeting(
            id: id,
            title: "홀사이즈 케이크 먹는 모임",
            intro: "서울권 카페에서 홀사이즈 케이크 먹어요",
            detail: "✱ 준비물\n케이크를 좋아하는 마음",
            posterURL: posterURL,
            backgroundMusic: nil,
            startAt: Date(timeIntervalSince1970: 1_782_986_400),
            place: place,
            region: Region(id: "1126000000", province: "서울특별시", district: "중랑구"),
            capacity: 14,
            joinedCount: 11,
            recentApplicantCount: 0,
            ageRange: AgeRange(minAge: 20, maxAge: 29),
            genderRestriction: .female,
            joinType: .instant,
            category: Interest(id: "food", name: "푸드/드링크"),
            status: .ended,
            host: host,
            episode: episode,
            myParticipation: .host,
            joinQuestions: [],
            notificationRequestCount: 16,
            isNotificationRequested: false
        )
    }

    static func series(id: String = "series-1", episodeCount: Int = 12) -> Series {
        Series(
            id: id,
            title: "홍제천 야간 산책 시리즈",
            intro: nil,
            coverImageURL: nil,
            host: host,
            episodeCount: episodeCount,
            participantCount: 30,
            momentCount: 0,
            recruitingMeetings: [],
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }

    /// 시리즈 회차 모임. id 는 `episode-<회차>` 다.
    static func episode(_ number: Int, seriesID: String = "series-1") -> Meeting {
        meeting(id: "episode-\(number)", episode: SeriesEpisode(seriesID: seriesID, number: number))
    }
}

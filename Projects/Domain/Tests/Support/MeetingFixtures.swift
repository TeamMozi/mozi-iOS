import Domain
import Foundation

enum MeetingFixtures {
    static let place = Place(
        name: "CGV 용산아이파크몰",
        address: "서울 용산구 한강대로23길 55",
        latitude: 37.5296,
        longitude: 126.9653
    )

    static let host = MeetingHost(
        userID: "host-1",
        nickname: "모지장",
        profileImageURL: nil,
        introduction: nil,
        hostedCount: nil,
        participatedCount: nil
    )

    static func meeting(id: String = "meeting-1", myParticipation: MyParticipation = .none) -> Meeting {
        Meeting(
            id: id,
            title: "뱅드림 몰아보고 코노가는 모임",
            intro: nil,
            detail: nil,
            posterURL: nil,
            backgroundMusic: BackgroundMusic(id: "music-1", title: "키즈나 뮤직"),
            startAt: Date(timeIntervalSince1970: 1_000),
            place: place,
            region: Region(id: "1126000000", province: "서울특별시", district: "중랑구"),
            capacity: 8,
            joinedCount: 3,
            recentApplicantCount: 0,
            ageRange: AgeRange(minAge: 20, maxAge: nil),
            genderRestriction: .any,
            joinType: .approval,
            category: Interest(id: "culture", name: "문화·예술"),
            status: .recruiting,
            host: host,
            episode: SeriesEpisode(seriesID: "series-1", number: 2),
            myParticipation: myParticipation,
            joinQuestions: ["좋아하는 밴드는?"],
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }

    static func draft(seriesID: String? = nil) -> MeetingDraft {
        MeetingDraft(
            title: "주말 아침 러닝 크루",
            intro: nil,
            detail: nil,
            poster: .keep,
            backgroundMusicID: nil,
            startAt: Date(timeIntervalSince1970: 2_000),
            place: place,
            capacity: 10,
            ageRange: AgeRange(minAge: nil, maxAge: nil),
            genderRestriction: .any,
            categoryID: "sports",
            seriesID: seriesID,
            joinQuestions: []
        )
    }

    static func series(id: String = "series-1") -> Series {
        Series(
            id: id,
            title: "뱅드림 필름 라이브 정주행",
            intro: nil,
            coverImageURL: nil,
            host: host,
            episodeCount: 2,
            participantCount: 10,
            momentCount: 0,
            recruitingMeetings: [meeting()],
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }
}

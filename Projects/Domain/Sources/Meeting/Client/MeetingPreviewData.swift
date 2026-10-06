import Foundation

/// `MeetingClient.previewValue` 의 가짜 데이터. 글자 수는 `MeetingLimit` 를 넘지 않는다.
enum MeetingPreviewData {
    static let createdMeetingID = "preview-meeting-created"

    static let host = MeetingHost(
        userID: "preview-host",
        nickname: "모지장",
        profileImageURL: nil,
        introduction: "영화 보고 노래 부르는 걸 좋아해요",
        hostedCount: 12,
        participatedCount: 30
    )

    static let categories = [
        Interest(id: "culture", name: "문화·예술"),
        Interest(id: "music", name: "음악"),
        Interest(id: "sports", name: "운동"),
        Interest(id: "food", name: "맛집·카페"),
    ]

    static let backgroundMusics = [
        BackgroundMusic(id: "preview-music-1", title: "키즈나 뮤직"),
        BackgroundMusic(id: "preview-music-2", title: "Hey-day 광소곡"),
    ]

    static let hostMeeting = Meeting(
        id: MeetingClient.PreviewID.host,
        title: "뱅드림 몰아보고 코노가는 모임",
        intro: "필름 라이브 몰아보고 코인노래방까지 함께 가요",
        detail: "극장에서 필름 라이브를 이어서 보고, 끝나면 근처 코인노래방에서 좋아하는 곡을 불러요.",
        posterURL: nil,
        backgroundMusic: backgroundMusics[0],
        startAt: Date(timeIntervalSince1970: 1_918_461_600),
        place: PlacePreviewData.yongsanCinema,
        region: PlacePreviewData.yongsan,
        capacity: 8,
        joinedCount: 5,
        recentApplicantCount: 3,
        ageRange: AgeRange(minAge: 20, maxAge: 35),
        genderRestriction: .any,
        joinType: .approval,
        category: categories[0],
        status: .recruiting,
        host: host,
        episode: SeriesEpisode(seriesID: SeriesClient.PreviewID.sample, number: 2),
        myParticipation: .host,
        joinQuestions: ["가장 좋아하는 밴드는 어디인가요?"],
        notificationRequestCount: 4,
        isNotificationRequested: false
    )

    static let memberMeeting = Meeting(
        id: MeetingClient.PreviewID.member,
        title: "한강에서 필름카메라 산책",
        intro: "필름카메라 들고 한강을 천천히 걸어요",
        detail: "망원한강공원에서 만나 한 롤씩 찍고 헤어져요. 카메라가 없으면 일회용도 좋아요.",
        posterURL: nil,
        backgroundMusic: nil,
        startAt: Date(timeIntervalSince1970: 1_918_530_000),
        place: PlacePreviewData.mangwonPark,
        region: PlacePreviewData.mapo,
        capacity: 6,
        joinedCount: 6,
        recentApplicantCount: 0,
        ageRange: AgeRange(minAge: nil, maxAge: nil),
        genderRestriction: .any,
        joinType: .instant,
        category: categories[0],
        status: .closed,
        host: host,
        episode: nil,
        myParticipation: .member,
        joinQuestions: [],
        notificationRequestCount: 0,
        isNotificationRequested: false
    )

    static let pendingMeeting = Meeting(
        id: MeetingClient.PreviewID.pending,
        title: "성수 카페 투어 같이 가요",
        intro: "성수 골목 카페 세 곳을 돌아요",
        detail: "연무장길 입구에서 만나요. 카페마다 음료 한 잔씩, 사진도 남겨요.",
        posterURL: nil,
        backgroundMusic: nil,
        startAt: Date(timeIntervalSince1970: 1_919_034_000),
        place: PlacePreviewData.seongsuStreet,
        region: PlacePreviewData.seongdong,
        capacity: 4,
        joinedCount: 2,
        recentApplicantCount: 5,
        ageRange: AgeRange(minAge: 25, maxAge: nil),
        genderRestriction: .female,
        joinType: .approval,
        category: categories[3],
        status: .recruiting,
        host: host,
        episode: nil,
        myParticipation: .pending,
        joinQuestions: ["좋아하는 카페 메뉴를 알려주세요"],
        notificationRequestCount: 0,
        isNotificationRequested: false
    )

    static let noneMeeting = Meeting(
        id: MeetingClient.PreviewID.none,
        title: "서울숲 아침 러닝 크루",
        intro: "서울숲 한 바퀴, 천천히 같이 달려요",
        detail: "처음 달리는 분도 괜찮아요. 5km 를 쉬엄쉬엄 달리고 근처에서 아침을 먹어요.",
        posterURL: nil,
        backgroundMusic: nil,
        startAt: Date(timeIntervalSince1970: 1_919_113_200),
        place: PlacePreviewData.seoulForest,
        region: PlacePreviewData.seongdong,
        capacity: 10,
        joinedCount: 7,
        recentApplicantCount: 2,
        ageRange: AgeRange(minAge: nil, maxAge: 40),
        genderRestriction: .any,
        joinType: .approval,
        category: categories[2],
        status: .recruiting,
        host: host,
        episode: nil,
        myParticipation: .none,
        joinQuestions: ["평소 얼마나 달리시나요?"],
        notificationRequestCount: 2,
        isNotificationRequested: true
    )

    static let meetings = [hostMeeting, memberMeeting, pendingMeeting, noneMeeting]

    /// 시리즈 `sample` 의 1회차. 2회차는 `hostMeeting` 이다.
    static let sampleFirstEpisode = Meeting(
        id: "preview-meeting-sample-1",
        title: "뱅드림 첫 필름 라이브 모임",
        intro: "필름 라이브 첫 편을 보고 코인노래방까지 가요",
        detail: nil,
        posterURL: nil,
        backgroundMusic: backgroundMusics[1],
        startAt: Date(timeIntervalSince1970: 1_758_016_800),
        place: PlacePreviewData.yongsanCinema,
        region: PlacePreviewData.yongsan,
        capacity: 8,
        joinedCount: 8,
        recentApplicantCount: 0,
        ageRange: AgeRange(minAge: 20, maxAge: 35),
        genderRestriction: .any,
        joinType: .approval,
        category: categories[0],
        status: .ended,
        host: host,
        episode: SeriesEpisode(seriesID: SeriesClient.PreviewID.sample, number: 1),
        myParticipation: .host,
        joinQuestions: [],
        notificationRequestCount: 0,
        isNotificationRequested: false
    )

    /// 시리즈 `walk` 의 회차 12개. 최신 회차부터다.
    static let walkEpisodes: [Meeting] = (1...12).reversed().map { number in
        walkEpisode(number: number)
    }

    /// 내가 연 모임 전부. 최신순(시작 시각 내림차순)이다. `hostedMeetings`·`episodes`·`hostedSeries` 가 이 목록을 쓴다.
    static let hostedMeetings: [Meeting] = ([hostMeeting, sampleFirstEpisode] + walkEpisodes)
        .sorted { $0.startAt > $1.startAt }

    static let members = [
        MeetingMember(userID: "preview-user-1", nickname: "필름덕후", profileImageURL: nil, status: .joined),
        MeetingMember(userID: "preview-user-2", nickname: "코노요정", profileImageURL: nil, status: .joined),
        MeetingMember(userID: "preview-user-3", nickname: "뱅드리머", profileImageURL: nil, status: .pending),
    ]

    static let notificationRequesters = [
        MeetingMember(userID: "preview-user-4", nickname: "다음회차기다림", profileImageURL: nil, status: .joined),
    ]

    static func meeting(id: String) throws -> Meeting {
        // 불러오기 목록의 모임도 상세를 읽을 수 있게 함께 찾는다.
        guard let meeting = (meetings + hostedMeetings).first(where: { $0.id == id }) else {
            throw MeetingError.notFound
        }
        return meeting
    }

    /// 고치기를 흉내 낸다. 초안 값만 바꾸고 서버가 정하는 칸은 `current` 에서 이어받는다. `seriesID` 는 무시한다.
    static func meeting(updating current: Meeting, with draft: MeetingDraft) -> Meeting {
        let drafted = meeting(from: draft, id: current.id)
        var updated = current
        updated.title = drafted.title
        updated.intro = drafted.intro
        updated.detail = drafted.detail
        updated.posterURL = draft.poster == .keep ? current.posterURL : drafted.posterURL
        updated.backgroundMusic = drafted.backgroundMusic
        updated.startAt = drafted.startAt
        updated.place = drafted.place
        updated.capacity = drafted.capacity
        updated.ageRange = drafted.ageRange
        updated.genderRestriction = drafted.genderRestriction
        updated.joinType = drafted.joinType
        updated.category = drafted.category
        updated.joinQuestions = drafted.joinQuestions
        return updated
    }

    /// 입력 초안으로 모임장이 막 만든 모임을 흉내 낸다.
    static func meeting(from draft: MeetingDraft, id: String) -> Meeting {
        let category = categories.first { $0.id == draft.categoryID }
            ?? Interest(id: draft.categoryID, name: draft.categoryID)
        return Meeting(
            id: id,
            title: draft.title,
            intro: draft.intro,
            detail: draft.detail,
            posterURL: nil,
            backgroundMusic: backgroundMusics.first { $0.id == draft.backgroundMusicID },
            startAt: draft.startAt,
            place: draft.place,
            region: nil,
            capacity: draft.capacity,
            joinedCount: 1,
            recentApplicantCount: 0,
            ageRange: draft.ageRange,
            genderRestriction: draft.genderRestriction,
            joinType: draft.joinType,
            category: category,
            status: .recruiting,
            host: host,
            episode: draft.seriesID.map { SeriesEpisode(seriesID: $0, number: 3) },
            myParticipation: .host,
            joinQuestions: draft.joinQuestions,
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }

    /// 2025-01-05(일) 10:00(KST)에 1회차를 열고 7일마다 연 끝난 회차.
    private static func walkEpisode(number: Int) -> Meeting {
        Meeting(
            id: "preview-meeting-walk-\(number)",
            title: "한강 필름 산책 \(number)회차",
            intro: "필름카메라 들고 한강을 천천히 걸어요",
            detail: nil,
            posterURL: nil,
            backgroundMusic: nil,
            startAt: Date(timeIntervalSince1970: 1_736_038_800 + TimeInterval(number - 1) * 604_800),
            place: PlacePreviewData.mangwonPark,
            region: PlacePreviewData.mapo,
            capacity: 6,
            joinedCount: 5,
            recentApplicantCount: 0,
            ageRange: AgeRange(minAge: nil, maxAge: nil),
            genderRestriction: .any,
            joinType: .instant,
            category: categories[0],
            status: .ended,
            host: host,
            episode: SeriesEpisode(seriesID: SeriesClient.PreviewID.walk, number: number),
            myParticipation: .host,
            joinQuestions: [],
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
    }
}

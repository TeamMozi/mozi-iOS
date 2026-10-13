import Domain
@testable import Feature
import Foundation
import XCTest

final class MeetingDisplayFormatTests: XCTestCase {
    /// 2026-07-16(목) 16:00 KST
    private let start = Date(timeIntervalSince1970: 1_784_185_200)

    func test_모임_상태는_띄어_쓰고_회차_카드_상태는_붙여_쓴다() {
        let statuses: [MeetingStatus] = [.recruiting, .closed, .ended]
        XCTAssertEqual(statuses.map(MeetingDisplayFormat.statusTitle), ["모집 중", "모집 마감", "종료"])
        XCTAssertEqual(statuses.map(MeetingDisplayFormat.episodeStatusTitle), ["모집중", "모집마감", "종료"])
    }

    func test_일정은_월일_요일_오전오후_시각으로_적는다() {
        XCTAssertEqual(MeetingDisplayFormat.schedule(start), "7월 16일 (목), 오후 4:00")
    }

    func test_인원은_명을_붙인다() {
        XCTAssertEqual(MeetingDisplayFormat.joinedSummary(8), "8명 참여")
        XCTAssertEqual(MeetingDisplayFormat.capacity(8), "8명")
        XCTAssertEqual(MeetingDisplayFormat.participants(8), "8명 참여 중")
        XCTAssertEqual(MeetingDisplayFormat.recentApplicants(8), "최근 일주일동안 8명이 신청했어요")
    }

    func test_나이는_십년_단위로_적고_비면_누구나() {
        XCTAssertEqual(MeetingDisplayFormat.ageRange(AgeRange(minAge: 20, maxAge: 35)), "20대~30대")
        XCTAssertEqual(MeetingDisplayFormat.ageRange(AgeRange(minAge: 20, maxAge: 29)), "20대")
        XCTAssertEqual(MeetingDisplayFormat.ageRange(AgeRange(minAge: 25, maxAge: nil)), "20대 이상")
        XCTAssertEqual(MeetingDisplayFormat.ageRange(AgeRange(minAge: nil, maxAge: 40)), "40대 이하")
        XCTAssertEqual(MeetingDisplayFormat.ageRange(AgeRange(minAge: nil, maxAge: nil)), "누구나")
    }

    func test_성별과_가입_방식_글() {
        let restrictions: [GenderRestriction] = [.any, .male, .female]
        XCTAssertEqual(restrictions.map(MeetingDisplayFormat.gender), ["누구나", "남자만", "여자만"])
        XCTAssertEqual(MeetingDisplayFormat.joinType(.approval), "승인 후 가입")
        XCTAssertEqual(MeetingDisplayFormat.joinType(.instant), "바로 가입")
    }

    func test_모임_관리_보조글은_날짜와_주소_앞_두_낱말이다() {
        XCTAssertEqual(
            MeetingDisplayFormat.managementSubtitle(startAt: start, address: "서울 마포구 동교동 165"),
            "2026/07/16 · 서울 마포구"
        )
        XCTAssertEqual(MeetingDisplayFormat.managementSubtitle(startAt: start, address: ""), "2026/07/16")
    }

    func test_위젯_보조글은_날짜_요일과_장소_이름이다() {
        XCTAssertEqual(
            MeetingDisplayFormat.widgetSubtitle(startAt: start, placeName: "히든스테이 홍대"),
            "2026/7/16 (목) · 히든스테이 홍대"
        )
    }

    func test_회차_카드는_월일과_요일과_회차를_따로_적는다() {
        // 2026-08-12(수) 19:00 KST
        let date = Date(timeIntervalSince1970: 1_786_528_800)
        XCTAssertEqual(MeetingDisplayFormat.episodeDay(date), "8/12")
        XCTAssertEqual(MeetingDisplayFormat.episodeWeekday(date), "수")
        XCTAssertEqual(MeetingDisplayFormat.episodeNumber(31), "31회차")
    }

    func test_알림_보낸_시각은_24시간_시분이다() {
        // 2026-07-16 14:40 KST
        XCTAssertEqual(MeetingDisplayFormat.sentTime(Date(timeIntervalSince1970: 1_784_180_400)), "14:40")
    }

    func test_모임장_기록과_시리즈_요약() {
        XCTAssertEqual(MeetingDisplayFormat.hostRecord(hostedCount: 12, participatedCount: 34), "누적 개최 12회 · 참여 34회")
        XCTAssertNil(MeetingDisplayFormat.hostRecord(hostedCount: nil, participatedCount: 34))
        let series = Series(
            id: "series-1",
            title: "걸밴드 오타쿠 모임 시리즈",
            intro: nil,
            coverImageURL: nil,
            host: MeetingHost(
                userID: "host-1",
                nickname: "모지장",
                profileImageURL: nil,
                introduction: nil,
                hostedCount: nil,
                participatedCount: nil
            ),
            episodeCount: 34,
            participantCount: 148,
            momentCount: 345,
            recruitingMeetings: [],
            notificationRequestCount: 0,
            isNotificationRequested: false
        )
        XCTAssertEqual(MeetingDisplayFormat.seriesSummary(series), "34회차 · 148명 참여 · 345개 모먼트")
        XCTAssertEqual(MeetingDisplayFormat.seriesSummaryParts(series), ["34회차", "148명 참여", "345개 모먼트"])
        XCTAssertEqual(
            MeetingDisplayFormat.hostRecordParts(hostedCount: 12, participatedCount: 34),
            ["누적 개최 12회", "참여 34회"]
        )
        XCTAssertNil(MeetingDisplayFormat.hostRecordParts(hostedCount: 12, participatedCount: nil))
    }
}

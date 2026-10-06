import Domain
import XCTest

final class SeriesModelTests: XCTestCase {
    func test_시리즈_칸이_같으면_같은_시리즈() {
        XCTAssertEqual(MeetingFixtures.series(), MeetingFixtures.series())
        XCTAssertNotEqual(MeetingFixtures.series(id: "series-1"), MeetingFixtures.series(id: "series-2"))
    }

    func test_회차_칸이_같으면_같은_회차() {
        XCTAssertEqual(SeriesEpisode(seriesID: "s1", number: 2), SeriesEpisode(seriesID: "s1", number: 2))
        XCTAssertNotEqual(SeriesEpisode(seriesID: "s1", number: 2), SeriesEpisode(seriesID: "s1", number: 3))
    }

    func test_시리즈_입력초안_칸이_같으면_같은_초안() {
        XCTAssertEqual(
            SeriesDraft(title: "정주행", intro: nil, meetingIDs: ["m1", "m2"]),
            SeriesDraft(title: "정주행", intro: nil, meetingIDs: ["m1", "m2"])
        )
        XCTAssertEqual(
            SeriesUpdateDraft(title: "정주행", intro: "소개", cover: .remove),
            SeriesUpdateDraft(title: "정주행", intro: "소개", cover: .remove)
        )
        XCTAssertNotEqual(
            SeriesUpdateDraft(title: "정주행", intro: nil, cover: .keep),
            SeriesUpdateDraft(title: "정주행", intro: nil, cover: .remove)
        )
    }

    func test_시리즈에러_메시지가_다르면_다른_에러() {
        XCTAssertEqual(SeriesError.validation(message: "a"), SeriesError.validation(message: "a"))
        XCTAssertNotEqual(SeriesError.validation(message: "a"), SeriesError.validation(message: "b"))
    }

    func test_시리즈_상한_상수는_스펙_값() {
        XCTAssertEqual(SeriesLimit.titleMaxLength, 20)
        XCTAssertEqual(SeriesLimit.introMaxLength, 50)
    }

    func test_시리즈별_칸이_같으면_같은_시리즈별() {
        let hosted = HostedSeries(series: MeetingFixtures.series(), recentMeetings: [MeetingFixtures.meeting()])
        XCTAssertEqual(
            hosted,
            HostedSeries(series: MeetingFixtures.series(), recentMeetings: [MeetingFixtures.meeting()])
        )
        XCTAssertNotEqual(hosted, HostedSeries(series: MeetingFixtures.series(), recentMeetings: []))
    }

    func test_시리즈별_최근모임_상한은_3() {
        XCTAssertEqual(HostedSeries.recentMeetingLimit, 3)
    }
}

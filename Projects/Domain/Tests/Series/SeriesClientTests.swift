import Domain
import XCTest

final class SeriesClientTests: XCTestCase {
    func test_SeriesClient_testValue는_생성_가능() {
        // testValue 는 SeriesClient.swift 의 TestDependencyKey 확장이 선언한다.
        // @DependencyClient 는 미구현 클로저를 채운 init 을 제공한다.
        _ = SeriesClient.testValue
    }

    func test_SeriesClient_previewValue는_생성_가능() {
        _ = SeriesClient.previewValue
    }

    func test_previewValue_가짜_시리즈는_글자수_상한을_넘지_않음() async throws {
        let series = try await SeriesClient.previewValue.series(id: SeriesClient.PreviewID.sample)
        XCTAssertLessThanOrEqual(series.title.count, SeriesLimit.titleMaxLength)
        XCTAssertLessThanOrEqual(series.intro?.count ?? 0, SeriesLimit.introMaxLength)
        for meeting in series.recruitingMeetings {
            XCTAssertLessThanOrEqual(meeting.title.count, MeetingLimit.titleMaxLength, meeting.title)
            XCTAssertEqual(meeting.status, .recruiting, meeting.title)
        }
    }

    func test_previewValue_모르는_id면_notFound() async {
        do {
            _ = try await SeriesClient.previewValue.series(id: "unknown")
            XCTFail("notFound 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? SeriesError, .notFound)
        }
    }

    func test_previewValue_시리즈를_고치면_새_제목과_소개를_돌려줌() async throws {
        let draft = SeriesUpdateDraft(title: "필름 라이브 정주행", intro: nil, cover: .keep)
        let series = try await SeriesClient.previewValue.update(id: SeriesClient.PreviewID.sample, draft: draft)
        XCTAssertEqual(series.title, "필름 라이브 정주행")
        XCTAssertNil(series.intro)
    }

    func test_더보기_첫_요청은_0번_페이지_5개() {
        XCTAssertEqual(SeriesClient.moreEpisodesFirstPage, PageRequest(page: 0, size: 5))
    }

    func test_previewValue_여러_페이지_시리즈도_글자수_상한을_넘지_않음() async throws {
        let series = try await SeriesClient.previewValue.series(id: SeriesClient.PreviewID.walk)
        XCTAssertLessThanOrEqual(series.title.count, SeriesLimit.titleMaxLength)
        XCTAssertLessThanOrEqual(series.intro?.count ?? 0, SeriesLimit.introMaxLength)
    }

    func test_previewValue_회차_첫_페이지는_최신_회차_5개와_다음_페이지_요청() async throws {
        let page = try await SeriesClient.previewValue.episodes(
            seriesID: SeriesClient.PreviewID.walk,
            page: SeriesClient.moreEpisodesFirstPage
        )
        XCTAssertEqual(page.items.compactMap(\.episode?.number), [12, 11, 10, 9, 8])
        XCTAssertEqual(page.next, PageRequest(page: 1, size: 5))
    }

    func test_previewValue_회차_마지막_페이지는_남은_2개와_next_nil() async throws {
        let page = try await SeriesClient.previewValue.episodes(
            seriesID: SeriesClient.PreviewID.walk,
            page: PageRequest(page: 2, size: 5)
        )
        XCTAssertEqual(page.items.compactMap(\.episode?.number), [2, 1])
        XCTAssertNil(page.next)
    }

    func test_previewValue_회차_범위밖이나_잘못된_요청은_빈목록과_next_nil() async throws {
        let requests = [
            PageRequest(page: 3, size: 5),
            PageRequest(page: Int.max, size: 5),
            PageRequest(page: 0, size: 0),
            PageRequest(page: 0, size: -1),
            PageRequest(page: -1, size: 5),
        ]
        for request in requests {
            let page = try await SeriesClient.previewValue.episodes(
                seriesID: SeriesClient.PreviewID.walk,
                page: request
            )
            XCTAssertTrue(page.items.isEmpty, "\(request)")
            XCTAssertNil(page.next, "\(request)")
        }
    }

    func test_previewValue_모르는_시리즈의_회차는_notFound() async {
        do {
            _ = try await SeriesClient.previewValue.episodes(seriesID: "unknown", page: .first)
            XCTFail("notFound 를 던져야 한다")
        } catch {
            XCTAssertEqual(error as? SeriesError, .notFound)
        }
    }

    func test_previewValue_회차를_끝까지_넘기면_시리즈_회차수만큼_최신순으로_돌려줌() async throws {
        for id in [SeriesClient.PreviewID.sample, SeriesClient.PreviewID.walk] {
            let series = try await SeriesClient.previewValue.series(id: id)
            var request: PageRequest? = SeriesClient.moreEpisodesFirstPage
            var episodes: [Meeting] = []
            var pageCount = 0
            while let current = request, pageCount < 10 {
                let page = try await SeriesClient.previewValue.episodes(seriesID: id, page: current)
                episodes += page.items
                request = page.next
                pageCount += 1
            }
            XCTAssertNil(request, id)
            XCTAssertEqual(episodes.count, series.episodeCount, id)
            XCTAssertTrue(episodes.allSatisfy { $0.episode?.seriesID == id }, id)
            XCTAssertEqual(episodes.map(\.startAt), episodes.map(\.startAt).sorted(by: >), id)
            for meeting in episodes {
                XCTAssertLessThanOrEqual(meeting.title.count, MeetingLimit.titleMaxLength, meeting.title)
            }
        }
    }

    func test_previewValue_시리즈별_첫_페이지는_시리즈_둘과_next_nil() async throws {
        let page = try await SeriesClient.previewValue.hostedSeries(page: .first)
        XCTAssertEqual(page.items.map(\.series.id), [SeriesClient.PreviewID.sample, SeriesClient.PreviewID.walk])
        XCTAssertNil(page.next)
    }

    func test_previewValue_시리즈별_최근모임은_3개이하이고_회차_목록의_앞부분() async throws {
        let page = try await SeriesClient.previewValue.hostedSeries(page: .first)
        for hosted in page.items {
            let episodes = try await SeriesClient.previewValue.episodes(seriesID: hosted.series.id, page: .first)
            XCTAssertLessThanOrEqual(hosted.recentMeetings.count, HostedSeries.recentMeetingLimit, hosted.series.id)
            XCTAssertEqual(
                hosted.recentMeetings,
                Array(episodes.items.prefix(HostedSeries.recentMeetingLimit)),
                hosted.series.id
            )
        }
        XCTAssertEqual(page.items.last?.recentMeetings.count, HostedSeries.recentMeetingLimit)
    }

    func test_previewValue_시리즈별_size가_1이면_한_시리즈씩_넘김() async throws {
        let first = try await SeriesClient.previewValue.hostedSeries(page: PageRequest(page: 0, size: 1))
        XCTAssertEqual(first.items.map(\.series.id), [SeriesClient.PreviewID.sample])
        XCTAssertEqual(first.next, PageRequest(page: 1, size: 1))

        let second = try await SeriesClient.previewValue.hostedSeries(page: PageRequest(page: 1, size: 1))
        XCTAssertEqual(second.items.map(\.series.id), [SeriesClient.PreviewID.walk])
        XCTAssertNil(second.next)
    }

    func test_previewValue_시리즈별_size가_0이하거나_page가_음수면_빈목록과_next_nil() async throws {
        let requests = [PageRequest(page: 0, size: 0), PageRequest(page: 0, size: -1), PageRequest(page: -1, size: 20)]
        for request in requests {
            let page = try await SeriesClient.previewValue.hostedSeries(page: request)
            XCTAssertTrue(page.items.isEmpty, "\(request)")
            XCTAssertNil(page.next, "\(request)")
        }
    }
}

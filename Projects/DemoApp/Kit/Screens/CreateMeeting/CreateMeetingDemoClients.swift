import Domain
import Foundation
import SharedDesignSystem
import SwiftUI
import ThirdParty
import UIKit

/// 「만들기」 데모 상태별 가짜 Client. Domain `previewValue` 를 바탕으로 상태마다 바꿀 곳만 덮어쓴다.
public enum CreateMeetingDemoClients {
    public static func meetingClient(for state: CreateMeetingDemoState, posterURL: URL?) -> MeetingClient {
        let preview = MeetingClient.previewValue
        var client = preview
        client.hostedMeetings = hostedMeetings(for: state, posterURL: posterURL)
        switch state {
        case .createFailed:
            // 알 수 없는 오류다. 화면은 만들기 문구를 띄운다
            client.create = { _ in throw MeetingError.unknown(message: "") }
            client.createEncore = { _ in throw MeetingError.unknown(message: "") }
        case .seriesOnlyFailed:
            client.createEncore = { draft in
                let meeting = try await preview.create(draft: draft.meeting)
                return .meetingOnly(meeting, .network)
            }
        case .firstCreate, .filledForm, .previousMeeting, .previousPoster, .placeEmpty, .created:
            break
        }
        return client
    }

    public static func seriesClient(for state: CreateMeetingDemoState) -> SeriesClient {
        SeriesClient.previewValue
    }

    /// 「장소 검색 결과 없음」 만 0건이다. 그 밖에는 어떤 검색어에도 가짜 장소를 모두 돌려준다.
    /// Domain 가짜 검색은 빈 검색어에 전부를 준다.
    public static func placeClient(for state: CreateMeetingDemoState) -> PlaceClient {
        let preview = PlaceClient.previewValue
        var client = preview
        client.search = { _ in
            state == .placeEmpty ? [] : try await preview.search(query: "")
        }
        return client
    }

    /// 「처음 만들기」 는 빈 목록이다. 그 밖에는 첫 페이지 맨 앞에 시리즈에 안 묶인 지난 모임을 더한다(2회차 흐름).
    /// Domain 가짜 모임은 모두 시리즈에 묶여 있어 3회차 흐름이 된다.
    private static func hostedMeetings(
        for state: CreateMeetingDemoState,
        posterURL: URL?
    ) -> @Sendable (PageRequest) async throws -> Page<Meeting> {
        let preview = MeetingClient.previewValue
        return { request in
            guard state != .firstCreate else {
                return Page(items: [], next: nil)
            }
            var page = try await preview.hostedMeetings(page: request)
            if request.page == 0 {
                page.items.insert(CreateMeetingDemoData.unboundMeeting(posterURL: nil), at: 0)
            }
            if state == .previousPoster {
                page.items = page.items.map { meeting in
                    var meeting = meeting
                    meeting.posterURL = posterURL
                    return meeting
                }
            }
            return page
        }
    }
}

/// 「만들기」 데모의 가짜 데이터.
public enum CreateMeetingDemoData {
    static let createdMeetingTitle = "홀사이즈 케이크 먹는 모임"

    /// 「입력 다 채운」 상태들의 값. 카테고리는 `InterestClient.previewValue` 목록에, 장소는 Domain 가짜 장소(서울숲)에 있다.
    static let category = Interest(id: "preview-interest-food", name: "푸드/드링크")
    static let filledTitle = "서울숲 피크닉 모임"
    static let place = Place(name: "서울숲", address: "서울 성동구 뚝섬로 273", latitude: 37.5444, longitude: 127.0374)
    static let capacity = 8
    /// 「시리즈 정보에서 → 누르면 연결만 실패」 에 채운 시리즈명.
    static let seriesTitle = "케이크 시리즈"

    /// 2회차 흐름을 보려고 더한 지난 모임. 시리즈에 묶여 있지 않다. 2026-07-22 19:00(한국 시간)에 끝났다.
    static func unboundMeeting(posterURL: URL?) -> Meeting {
        Meeting(
            id: "demo-meeting-unbound",
            title: "홀사이즈 케이크 먹는 모임",
            intro: "서울권 카페에서 홀사이즈 케이크 먹어요",
            detail: "✱ 진행 순서\n1. 카페 앞에서 만나요\n2. 다 같이 케이크 고르고 주문해요",
            posterURL: posterURL,
            backgroundMusic: nil,
            startAt: Date(timeIntervalSince1970: 1_784_714_400),
            place: Place(name: "중앙로 12-3", address: "서울 중랑구 중앙로 12-3", latitude: 37.6063, longitude: 127.0925),
            region: Region(id: "1126000000", province: "서울특별시", district: "중랑구"),
            capacity: 14,
            joinedCount: 11,
            recentApplicantCount: 0,
            ageRange: AgeRange(minAge: 20, maxAge: 29),
            genderRestriction: .any,
            joinType: .instant,
            category: Interest(id: "preview-interest-food", name: "푸드/드링크"),
            status: .ended,
            host: MeetingHost(
                userID: "preview-host",
                nickname: "모지장",
                profileImageURL: nil,
                introduction: nil,
                hostedCount: nil,
                participatedCount: nil
            ),
            episode: nil,
            myParticipation: .host,
            joinQuestions: [],
            notificationRequestCount: 16,
            isNotificationRequested: false
        )
    }
}

/// 「지난 포스터 불러오기」 의 포스터 그림. 서버 없이 보이도록 단색 그림을 임시 폴더에 써 두고 그 파일 주소를 쓴다.
@MainActor
public enum CreateMeetingDemoPoster {
    public static func fileURL() -> URL? {
        let url = FileManager.default.temporaryDirectory.appending(path: "demo-previous-poster.jpg")
        if FileManager.default.fileExists(atPath: url.path()) {
            return url
        }
        let size = CGSize(width: 600, height: 800)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let color = UIColor(Color.ds.fill.accent.default)
            .resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let data = renderer.jpegData(withCompressionQuality: 0.8) { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        do {
            try data.write(to: url)
        } catch {
            return nil
        }
        return url
    }
}

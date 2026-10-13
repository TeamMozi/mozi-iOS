import Domain
import Foundation

/// 모임 상세 흐름 화면들이 함께 쓰는 표시 글. 시각은 한국 시간으로 적는다.
enum MeetingDisplayFormat {
    static func statusTitle(_ status: MeetingStatus) -> String {
        switch status {
        case .recruiting: "모집 중"
        case .closed: "모집 마감"
        case .ended: "종료"
        }
    }

    /// 시리즈 회차 카드의 상태. 시안 표기가 붙여 쓴다(「모집중」).
    static func episodeStatusTitle(_ status: MeetingStatus) -> String {
        switch status {
        case .recruiting: "모집중"
        case .closed: "모집마감"
        case .ended: "종료"
        }
    }

    /// 「7월 16일 (목), 오후 4:00」
    static func schedule(_ date: Date) -> String {
        string(date, format: "M월 d일 (E), a h:mm")
    }

    static func joinedSummary(_ count: Int) -> String {
        "\(count)명 참여"
    }

    static func capacity(_ capacity: Int) -> String {
        "\(capacity)명"
    }

    static func participants(_ count: Int) -> String {
        "\(count)명 참여 중"
    }

    static func recentApplicants(_ count: Int) -> String {
        "최근 일주일동안 \(count)명이 신청했어요"
    }

    static func ageRange(_ range: AgeRange) -> String {
        switch (range.minAge.map(decade), range.maxAge.map(decade)) {
        case let (min?, max?):
            min == max ? "\(min)대" : "\(min)대~\(max)대"
        case let (min?, nil):
            "\(min)대 이상"
        case let (nil, max?):
            "\(max)대 이하"
        case (nil, nil):
            "누구나"
        }
    }

    static func gender(_ restriction: GenderRestriction) -> String {
        switch restriction {
        case .any: "누구나"
        case .male: "남자만"
        case .female: "여자만"
        }
    }

    static func joinType(_ type: JoinType) -> String {
        switch type {
        case .approval: "승인 후 가입"
        case .instant: "바로 가입"
        }
    }

    /// 「2026/07/16 · 서울 마포구」. 동네는 주소의 앞 두 낱말이다.
    static func managementSubtitle(startAt: Date, address: String) -> String {
        let date = string(startAt, format: "yyyy/MM/dd")
        let area = address.split(separator: " ").prefix(2).joined(separator: " ")
        return area.isEmpty ? date : "\(date) · \(area)"
    }

    /// 「2026/7/16 (목) · 히든스테이 홍대」
    static func widgetSubtitle(startAt: Date, placeName: String) -> String {
        "\(string(startAt, format: "yyyy/M/d (E)")) · \(placeName)"
    }

    static func episodeDay(_ date: Date) -> String {
        string(date, format: "M/d")
    }

    static func episodeWeekday(_ date: Date) -> String {
        string(date, format: "E")
    }

    static func episodeNumber(_ number: Int) -> String {
        "\(number)회차"
    }

    static func sentTime(_ date: Date) -> String {
        string(date, format: "HH:mm")
    }

    /// 모임장 구간의 「누적 개최 12회 · 참여 34회」. 둘 중 하나라도 없으면 줄을 그리지 않는다.
    static func hostRecord(hostedCount: Int?, participatedCount: Int?) -> String? {
        hostRecordParts(hostedCount: hostedCount, participatedCount: participatedCount)?
            .joined(separator: partSeparator)
    }

    /// `hostRecord` 의 낱말 배열. 화면은 낱말 사이에 점을 그린다.
    static func hostRecordParts(hostedCount: Int?, participatedCount: Int?) -> [String]? {
        guard let hostedCount, let participatedCount else { return nil }
        return ["누적 개최 \(hostedCount)회", "참여 \(participatedCount)회"]
    }

    /// 시리즈 소개의 「34회차 · 148명 참여 · 345개 모먼트」
    static func seriesSummary(_ series: Series) -> String {
        seriesSummaryParts(series).joined(separator: partSeparator)
    }

    /// `seriesSummary` 의 낱말 배열. 화면은 낱말 사이에 점을 그린다.
    static func seriesSummaryParts(_ series: Series) -> [String] {
        ["\(series.episodeCount)회차", "\(series.participantCount)명 참여", "\(series.momentCount)개 모먼트"]
    }

    private static let partSeparator = " · "

    private static func decade(_ age: Int) -> Int {
        age / 10 * 10
    }

    private static func string(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

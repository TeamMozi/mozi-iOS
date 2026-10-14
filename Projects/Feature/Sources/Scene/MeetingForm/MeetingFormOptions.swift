import Domain
import Foundation
import SharedDesignSystem

/// 모임 만들기 화면의 고정 값.
public enum MeetingFormOptions {
    public static let capacities = Array(MeetingLimit.capacityRange)
    /// 연령대 직접 입력 메뉴의 나이.
    public static let customAges = Array(14...80)
    /// 성별 메뉴 순서. 시안 그대로다.
    public static let genders: [GenderRestriction] = [.female, .male, .any]
}

/// 연령대 칩. 하나만 고른다. 「20대」 는 20~29세다.
public enum MeetingAgeOption: String, CaseIterable, Equatable, Sendable {
    case anyone
    case teens
    case twenties
    case thirties
    case forties
    case fifties
    case sixties
    case custom

    public var title: String {
        switch self {
        case .anyone: "누구나"
        case .teens: "10대"
        case .twenties: "20대"
        case .thirties: "30대"
        case .forties: "40대"
        case .fifties: "50대"
        case .sixties: "60대"
        case .custom: "직접 입력"
        }
    }

    private var decade: Int? {
        switch self {
        case .teens: 10
        case .twenties: 20
        case .thirties: 30
        case .forties: 40
        case .fifties: 50
        case .sixties: 60
        case .anyone, .custom: nil
        }
    }

    /// 이 칩의 나이 범위. 직접 입력이면 넘긴 나이를 쓴다.
    public func ageRange(customMin: Int?, customMax: Int?) -> AgeRange {
        if self == .custom {
            return AgeRange(minAge: customMin, maxAge: customMax)
        }
        guard let decade else { return AgeRange(minAge: nil, maxAge: nil) }
        return AgeRange(minAge: decade, maxAge: decade + 9)
    }

    /// 지난 모임의 나이 범위에 맞는 칩. 맞는 연령대가 없으면 직접 입력이다.
    public init(range: AgeRange) {
        if range.minAge == nil, range.maxAge == nil {
            self = .anyone
            return
        }
        self = Self.allCases.first { option in
            option.decade != nil && option.ageRange(customMin: nil, customMax: nil) == range
        } ?? .custom
    }
}

/// 모임 정보 칩. 누르면 「✱ 참가비」 같은 머리말 한 줄을 넣는다.
public enum MeetingDetailHeading: String, CaseIterable, Equatable, Sendable {
    case notice
    case fee
    case supplies
    case schedule
    case welcome
    case hostIntro

    public var title: String {
        switch self {
        case .notice: "안내사항"
        case .fee: "참가비"
        case .supplies: "준비물"
        case .schedule: "진행순서"
        case .welcome: "이런 분 환영해요"
        case .hostIntro: "모임장 소개"
        }
    }

    /// 커서 자리(없으면 끝)에 머리말 한 줄을 넣는다. 줄 가운데면 앞에서 줄을 바꾼다.
    /// 넣은 글이 `MeetingLimit.detailMaxLength` 를 넘으면 넣지 않고 nil 이다.
    /// - Parameter offset: UTF-16 위치. 여러 줄 칸이 알려 준 값이다.
    public func insert(into text: String, atUTF16Offset offset: Int?) -> MeetingDetailInsertion? {
        let length = text.utf16.count
        let location = min(max(offset ?? length, 0), length)
        let index = String.Index(utf16Offset: location, in: text)
        let startsLine = index == text.startIndex || text[text.index(before: index)] == "\n"
        let fragment = (startsLine ? "" : "\n") + "✱ \(title)\n"
        guard text.count + fragment.count <= MeetingLimit.detailMaxLength else { return nil }
        var result = text
        result.insert(contentsOf: fragment, at: index)
        return MeetingDetailInsertion(text: result, cursor: location + fragment.utf16.count)
    }
}

/// 머리말을 넣은 글과 그 뒤 커서 위치(UTF-16).
public struct MeetingDetailInsertion: Equatable, Sendable {
    public var text: String
    public var cursor: Int
}

/// 모임 만들기 화면의 표시 글.
enum MeetingFormFormat {
    /// 「2026. 8. 25」
    static func date(_ day: DesignCalendarDay) -> String {
        "\(day.year). \(day.month). \(day.day)"
    }

    /// 「9:41 AM」
    static func time(_ time: DesignClockTime) -> String {
        let hour = time.hour % 12 == 0 ? 12 : time.hour % 12
        let suffix = time.hour < 12 ? "AM" : "PM"
        return "\(hour):" + String(format: "%02d", time.minute) + " \(suffix)"
    }

    /// 「20세」
    static func ageText(_ age: Int) -> String {
        "\(age)세"
    }

    static func age(fromText text: String) -> Int? {
        Int(text.replacingOccurrences(of: "세", with: ""))
    }

    /// 연령대 줄 값. 직접 입력이면 「20~29세」, 최소만 「28세~」, 최대만 「~35세」, 둘 다 없으면 「직접 입력」 이다.
    static func ageSummary(option: MeetingAgeOption, range: AgeRange) -> String {
        guard option == .custom else { return option.title }
        switch (range.minAge, range.maxAge) {
        case let (minAge?, maxAge?): return "\(minAge)~\(maxAge)세"
        case let (minAge?, nil): return "\(minAge)세~"
        case let (nil, maxAge?): return "~\(maxAge)세"
        case (nil, nil): return option.title
        }
    }

    static func gender(_ gender: GenderRestriction) -> String {
        switch gender {
        case .any: "누구나"
        case .male: "남성"
        case .female: "여성"
        }
    }

    /// 나이 범위를 출생연도로 바꾼 안내. 양쪽이 다 있어야 보인다. 「1997년생부터 2006년생까지 모집해요.」
    static func birthYearCaption(range: AgeRange, thisYear: Int?) -> String? {
        guard let thisYear, let minAge = range.minAge, let maxAge = range.maxAge else { return nil }
        return "\(thisYear - maxAge)년생부터 \(thisYear - minAge)년생까지 모집해요."
    }
}

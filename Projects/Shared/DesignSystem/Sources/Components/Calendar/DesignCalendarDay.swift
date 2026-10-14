import Foundation

/// 달력의 하루. 시간대 없이 연·월·일만 갖는다.
public struct DesignCalendarDay: Hashable, Comparable, Sendable {
    public var year: Int
    public var month: Int
    public var day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// `date` 가 `calendar` 의 시간대에서 놓이는 하루.
    public init(_ date: Date, calendar: Calendar) {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: parts.year ?? 1, month: parts.month ?? 1, day: parts.day ?? 1)
    }

    /// 이 날이 들어 있는 달.
    public var calendarMonth: DesignCalendarMonth {
        DesignCalendarMonth(year: year, month: month)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

/// 달력이 보여 주는 달.
public struct DesignCalendarMonth: Hashable, Comparable, Sendable {
    public var year: Int
    public var month: Int

    public init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    /// `count` 달 뒤. 음수면 앞이다. 12월 다음은 다음 해 1월이다.
    public func adding(months count: Int) -> DesignCalendarMonth {
        let index = year * 12 + (month - 1) + count
        return DesignCalendarMonth(year: index / 12, month: index % 12 + 1)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }
}

/// 달력 칸 하나. 첫 주 앞과 마지막 주 뒤는 앞뒤 달의 날로 채운다.
public struct DesignCalendarCell: Hashable, Sendable {
    public var day: DesignCalendarDay
    public var isInMonth: Bool

    public init(day: DesignCalendarDay, isInMonth: Bool) {
        self.day = day
        self.isInMonth = isInMonth
    }
}

public enum DesignCalendarGrid {
    /// 일요일에 시작하는 주 단위 칸. 칸 수는 7의 배수다.
    public static func cells(for month: DesignCalendarMonth) -> [DesignCalendarCell] {
        let dayCount = numberOfDays(in: month)
        let leading = weekdayIndexOfFirstDay(in: month)
        let previous = month.adding(months: -1)
        let previousCount = numberOfDays(in: previous)
        var cells: [DesignCalendarCell] = []
        for offset in stride(from: leading, to: 0, by: -1) {
            let day = DesignCalendarDay(year: previous.year, month: previous.month, day: previousCount - offset + 1)
            cells.append(DesignCalendarCell(day: day, isInMonth: false))
        }
        for day in 1...dayCount {
            let current = DesignCalendarDay(year: month.year, month: month.month, day: day)
            cells.append(DesignCalendarCell(day: current, isInMonth: true))
        }
        let next = month.adding(months: 1)
        var nextDay = 1
        while cells.count % 7 != 0 {
            let following = DesignCalendarDay(year: next.year, month: next.month, day: nextDay)
            cells.append(DesignCalendarCell(day: following, isInMonth: false))
            nextDay += 1
        }
        return cells
    }

    /// 달의 주 수(4~6). 달력 높이가 이것을 따른다.
    public static func weekCount(for month: DesignCalendarMonth) -> Int {
        cells(for: month).count / 7
    }

    // 달력 칸은 시간대와 상관없다. UTC 그레고리력으로 센다.
    private static var gregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private static func firstDate(of month: DesignCalendarMonth) -> Date? {
        gregorian.date(from: DateComponents(year: month.year, month: month.month, day: 1))
    }

    private static func numberOfDays(in month: DesignCalendarMonth) -> Int {
        guard let first = firstDate(of: month) else { return 0 }
        return gregorian.range(of: .day, in: .month, for: first)?.count ?? 0
    }

    /// 1일의 요일. 일요일이 0 이다.
    private static func weekdayIndexOfFirstDay(in month: DesignCalendarMonth) -> Int {
        guard let first = firstDate(of: month) else { return 0 }
        return gregorian.component(.weekday, from: first) - 1
    }
}

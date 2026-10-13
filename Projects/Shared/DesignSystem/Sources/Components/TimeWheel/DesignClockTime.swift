import Foundation

/// 하루 안의 시각. 날짜와 시간대 없이 시·분만 갖는다.
public struct DesignClockTime: Hashable, Comparable, Sendable {
    /// 0~23
    public var hour: Int
    /// 0~59
    public var minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    /// 휠의 분 칸. `interval` 분마다이고, 0 이하면 1분마다다.
    public static func minuteOptions(interval: Int) -> [Int] {
        Array(stride(from: 0, to: 60, by: max(interval, 1)))
    }

    /// 날짜의 시·분. `calendar` 의 시간대로 읽는다.
    public init(_ date: Date, calendar: Calendar) {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        self.init(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
    }

    /// `reference` 와 같은 날의 이 시각. `calendar` 의 시간대로 놓는다.
    public func date(on reference: Date, calendar: Calendar) -> Date? {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: reference)
    }

    /// `minuteInterval` 분 칸에 맞지 않는 분을 바로 아래 칸으로 내린다. 0 이하면 그대로다.
    public func snapped(minuteInterval: Int) -> DesignClockTime {
        let interval = max(minuteInterval, 1)
        return DesignClockTime(hour: hour, minute: minute - minute % interval)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.hour, lhs.minute) < (rhs.hour, rhs.minute)
    }
}

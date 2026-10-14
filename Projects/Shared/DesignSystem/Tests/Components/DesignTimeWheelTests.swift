@testable import SharedDesignSystem
import UIKit
import XCTest

/// 시간 휠은 iOS 기본 시간 고르기(`UIDatePicker` 휠, 시·분) 하나다.
final class DesignTimeWheelTests: XCTestCase {
    private let seoul: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }()

    @MainActor
    func test_휠은_시_분만_고르는_iOS_기본_휠이고_분_간격을_받는다() {
        let picker = DesignTimeWheelBridge.makePicker(minuteInterval: 5)
        XCTAssertEqual(picker.datePickerMode, .time)
        XCTAssertEqual(picker.preferredDatePickerStyle, .wheels)
        XCTAssertEqual(picker.minuteInterval, 5)
    }

    @MainActor
    func test_분_간격이_0이하면_1분_간격이다() {
        XCTAssertEqual(DesignTimeWheelBridge.makePicker(minuteInterval: 0).minuteInterval, 1)
    }

    @MainActor
    func test_오전_오후_표시는_기기_설정을_따르도록_언어와_달력을_건드리지_않는다() {
        let picker = DesignTimeWheelBridge.makePicker(minuteInterval: 5)
        XCTAssertEqual(picker.locale, Locale.current)
        XCTAssertEqual(picker.calendar, Calendar.current)
    }

    func test_간격에_맞지_않는_분은_바로_아래_칸에_놓는다() {
        let sevenPast = DesignClockTime(hour: 9, minute: 7)
        let tenPast = DesignClockTime(hour: 9, minute: 10)
        XCTAssertEqual(sevenPast.snapped(minuteInterval: 5), DesignClockTime(hour: 9, minute: 5))
        XCTAssertEqual(tenPast.snapped(minuteInterval: 5), tenPast)
        XCTAssertEqual(sevenPast.snapped(minuteInterval: 0), sevenPast)
    }

    func test_시각을_날짜에_얹었다가_다시_꺼내면_같은_시각이다() throws {
        let reference = try XCTUnwrap(seoul.date(from: DateComponents(year: 2026, month: 7, day: 16, hour: 3)))
        let time = DesignClockTime(hour: 21, minute: 35)
        let date = try XCTUnwrap(time.date(on: reference, calendar: seoul))

        XCTAssertEqual(seoul.component(.day, from: date), 16)
        XCTAssertEqual(DesignClockTime(date, calendar: seoul), time)
    }

    @MainActor
    func test_넘긴_시각을_간격에_맞춰_휠에_건다() throws {
        let picker = DesignTimeWheelBridge.makePicker(minuteInterval: 5)
        picker.calendar = seoul
        picker.timeZone = seoul.timeZone
        DesignTimeWheelBridge.show(DesignClockTime(hour: 9, minute: 7), minuteInterval: 5, in: picker)

        XCTAssertEqual(DesignClockTime(picker.date, calendar: seoul), DesignClockTime(hour: 9, minute: 5))
    }
}

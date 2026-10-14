@testable import SharedDesignSystem
import XCTest

final class DesignCalendarTests: XCTestCase {
    func test_2026년_7월은_수요일에_시작해_앞을_6월_사흘로_채운다() {
        let cells = DesignCalendarGrid.cells(for: DesignCalendarMonth(year: 2026, month: 7))

        XCTAssertEqual(cells.prefix(4).map(\.day.day), [28, 29, 30, 1])
        XCTAssertEqual(cells.prefix(3).map(\.isInMonth), [false, false, false])
        XCTAssertEqual(
            cells[3],
            DesignCalendarCell(day: DesignCalendarDay(year: 2026, month: 7, day: 1), isInMonth: true)
        )
    }

    func test_달력_칸은_7의_배수이고_뒤를_다음_달로_채운다() {
        let cells = DesignCalendarGrid.cells(for: DesignCalendarMonth(year: 2026, month: 7))

        XCTAssertEqual(cells.count, 35)
        XCTAssertEqual(
            cells.last,
            DesignCalendarCell(day: DesignCalendarDay(year: 2026, month: 8, day: 1), isInMonth: false)
        )
    }

    func test_일요일에_시작해_토요일에_끝나는_달은_앞뒤를_채우지_않는다() {
        let cells = DesignCalendarGrid.cells(for: DesignCalendarMonth(year: 2026, month: 2))

        XCTAssertEqual(cells.count, 28)
        XCTAssertTrue(cells.allSatisfy(\.isInMonth))
        XCTAssertEqual(cells.first?.day, DesignCalendarDay(year: 2026, month: 2, day: 1))
    }

    func test_12월_다음_달은_다음_해_1월이다() {
        XCTAssertEqual(
            DesignCalendarMonth(year: 2026, month: 12).adding(months: 1),
            DesignCalendarMonth(year: 2027, month: 1)
        )
    }

    func test_1월_앞_달은_앞_해_12월이다() {
        XCTAssertEqual(
            DesignCalendarMonth(year: 2026, month: 1).adding(months: -1),
            DesignCalendarMonth(year: 2025, month: 12)
        )
    }

    func test_날짜는_연_월_일_순으로_비교한다() {
        XCTAssertLessThan(
            DesignCalendarDay(year: 2026, month: 7, day: 31),
            DesignCalendarDay(year: 2026, month: 8, day: 1)
        )
        XCTAssertLessThan(
            DesignCalendarDay(year: 2025, month: 12, day: 31),
            DesignCalendarDay(year: 2026, month: 1, day: 1)
        )
    }

    func test_시각은_달력의_시간대에서_하루가_된다() {
        // 2026-07-15 16:00 UTC 는 한국 시간 2026-07-16 01:00 이다
        let date = Date(timeIntervalSince1970: 1_784_131_200)
        var seoul = Calendar(identifier: .gregorian)
        seoul.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60) ?? .current

        XCTAssertEqual(DesignCalendarDay(date, calendar: seoul), DesignCalendarDay(year: 2026, month: 7, day: 16))
        XCTAssertEqual(
            DesignCalendarDay(date, calendar: seoul).calendarMonth,
            DesignCalendarMonth(year: 2026, month: 7)
        )
    }

    // MARK: 시안 값 (`2774:118148` › Calendar)

    func test_달력_칸_치수는_시안_날짜_44x48_요일_34_머리_24다() {
        XCTAssertEqual(DesignCalendarMetrics.dayWidth, 44)
        XCTAssertEqual(DesignCalendarMetrics.dayHeight, 48)
        XCTAssertEqual(DesignCalendarMetrics.markSize, 36)
        XCTAssertEqual(DesignCalendarMetrics.weekdayHeight, 34)
        XCTAssertEqual(DesignCalendarMetrics.weekdayHorizontalPadding, 1)
        XCTAssertEqual(DesignCalendarMetrics.headerHeight, 24)
        XCTAssertEqual(DesignCalendarMetrics.headerSpacing, 8)
        XCTAssertEqual(DesignCalendarMetrics.sectionSpacing, 4)
        XCTAssertEqual(DesignCalendarMetrics.arrowFrame, 24)
    }

    func test_화살표_글리프는_시안처럼_높이_13이다() {
        // 아이콘 `chevron` 의 글리프는 24 틀에서 높이 18 이다. 틀을 줄여 글리프를 13 으로 맞춘다.
        XCTAssertEqual(DesignCalendarMetrics.arrowIconSize * 18 / 24, 13, accuracy: 0.01)
    }

    func test_다섯_주_달력_높이는_시안_298이다() {
        XCTAssertEqual(DesignCalendarGrid.weekCount(for: DesignCalendarMonth(year: 2026, month: 7)), 5)
        XCTAssertEqual(DesignCalendarMetrics.height(weekCount: 5), 298)
    }

    func test_주가_하나_늘면_달력이_날짜_칸_높이_48만큼_길어진다() {
        XCTAssertEqual(DesignCalendarGrid.weekCount(for: DesignCalendarMonth(year: 2026, month: 2)), 4)
        XCTAssertEqual(DesignCalendarGrid.weekCount(for: DesignCalendarMonth(year: 2026, month: 8)), 6)
        XCTAssertEqual(DesignCalendarMetrics.height(weekCount: 4), 250)
        XCTAssertEqual(DesignCalendarMetrics.height(weekCount: 6), 346)
    }

    func test_년월_요일_날짜_글자는_text_neutral_secondary_화살표는_border_neutral_50이다() {
        assertTheme(DesignCalendarPalette.header, dark: 0xCACACEFF, light: 0x484753FF)
        assertTheme(DesignCalendarPalette.weekday, dark: 0xCACACEFF, light: 0x484753FF)
        assertTheme(DesignCalendarPalette.arrow, dark: 0x7A7887FF, light: 0x484753FF)
        assertTheme(
            DesignCalendarPalette.dayText(isEnabled: true, isSelected: false, isToday: false),
            dark: 0xCACACEFF,
            light: 0x484753FF
        )
    }

    func test_오늘은_테두리_text_accent_default_글자_text_accent_strong이다() {
        assertTheme(DesignCalendarPalette.todayRing, dark: 0xFFF489FF, light: 0xF6BB09FF)
        assertTheme(
            DesignCalendarPalette.dayText(isEnabled: true, isSelected: false, isToday: true),
            dark: 0xFFFFB9FF,
            light: 0xF1A727FF
        )
    }

    func test_고른_날은_text_accent_default_원에_inverse_글자_고를_수_없는_날은_faint다() {
        assertTheme(DesignCalendarPalette.selectedFill, dark: 0xFFF489FF, light: 0xF6BB09FF)
        assertTheme(
            DesignCalendarPalette.dayText(isEnabled: true, isSelected: true, isToday: true),
            dark: 0x000000FF,
            light: 0xFFFFFFFF
        )
        assertTheme(
            DesignCalendarPalette.dayText(isEnabled: false, isSelected: false, isToday: false),
            dark: 0x484753FF,
            light: 0xCACACEFF
        )
    }

    func test_글자_모양은_년월_SemiBold_16_요일_Medium_14_20_날짜_Medium_16_고른_날_SemiBold_16이다() {
        XCTAssertEqual(DesignCalendarMetrics.headerStyle, TextStyle.ds.headline.semiBold)
        XCTAssertEqual(DesignCalendarMetrics.dayStyle, TextStyle.ds.headline.medium)
        XCTAssertEqual(DesignCalendarMetrics.selectedDayStyle, TextStyle.ds.headline.semiBold)
        let weekday = DesignCalendarMetrics.weekdayStyle
        XCTAssertEqual(weekday.fontName, "Pretendard-Medium")
        XCTAssertEqual(weekday.size, 14)
        XCTAssertEqual(weekday.lineHeight, 20)
        XCTAssertEqual(weekday.letterSpacing, -0.5, accuracy: 0.0001)
    }
}

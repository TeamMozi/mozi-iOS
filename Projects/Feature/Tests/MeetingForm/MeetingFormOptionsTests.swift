import Domain
@testable import Feature
import SharedDesignSystem
import XCTest

final class MeetingFormOptionsTests: XCTestCase {
    func test_커서_자리가_줄_처음이면_머리말만_한_줄_넣는다() {
        let inserted = MeetingDetailHeading.fee.insert(into: "가나\n다라", atUTF16Offset: 3)
        XCTAssertEqual(inserted, MeetingDetailInsertion(text: "가나\n✱ 참가비\n다라", cursor: 9))
    }

    func test_커서가_없으면_끝에_줄을_바꿔_머리말을_넣는다() {
        let inserted = MeetingDetailHeading.fee.insert(into: "가나", atUTF16Offset: nil)
        XCTAssertEqual(inserted, MeetingDetailInsertion(text: "가나\n✱ 참가비\n", cursor: 9))
    }

    func test_빈_칸에는_머리말을_첫_줄에_넣는다() {
        let inserted = MeetingDetailHeading.welcome.insert(into: "", atUTF16Offset: nil)
        XCTAssertEqual(inserted, MeetingDetailInsertion(text: "✱ 이런 분 환영해요\n", cursor: 12))
    }

    func test_머리말을_넣어_500자를_넘으면_넣지_않는다() {
        let text = String(repeating: "가", count: 495)
        XCTAssertNil(MeetingDetailHeading.fee.insert(into: text, atUTF16Offset: nil))
    }

    func test_연령대_20대는_20세부터_29세다() {
        XCTAssertEqual(
            MeetingAgeOption.twenties.ageRange(customMin: nil, customMax: nil),
            AgeRange(minAge: 20, maxAge: 29)
        )
    }

    func test_연령대_누구나는_제한이_없다() {
        XCTAssertEqual(
            MeetingAgeOption.anyone.ageRange(customMin: 30, customMax: 40),
            AgeRange(minAge: nil, maxAge: nil)
        )
    }

    func test_맞는_연령대가_없는_나이_범위는_직접_입력이다() {
        XCTAssertEqual(MeetingAgeOption(range: AgeRange(minAge: 20, maxAge: 29)), .twenties)
        XCTAssertEqual(MeetingAgeOption(range: AgeRange(minAge: nil, maxAge: nil)), .anyone)
        XCTAssertEqual(MeetingAgeOption(range: AgeRange(minAge: 25, maxAge: 35)), .custom)
    }

    func test_시각은_오전_오후_12시간제로_보인다() {
        XCTAssertEqual(MeetingFormFormat.time(DesignClockTime(hour: 9, minute: 41)), "9:41 AM")
        XCTAssertEqual(MeetingFormFormat.time(DesignClockTime(hour: 0, minute: 5)), "12:05 AM")
        XCTAssertEqual(MeetingFormFormat.time(DesignClockTime(hour: 20, minute: 0)), "8:00 PM")
    }

    func test_날짜는_점으로_나눠_보인다() {
        XCTAssertEqual(MeetingFormFormat.date(DesignCalendarDay(year: 2026, month: 8, day: 25)), "2026. 8. 25")
    }

    func test_나이_범위를_출생연도_안내로_바꾼다() {
        XCTAssertEqual(
            MeetingFormFormat.birthYearCaption(range: AgeRange(minAge: 20, maxAge: 29), thisYear: 2026),
            "1997년생부터 2006년생까지 모집해요."
        )
        XCTAssertNil(MeetingFormFormat.birthYearCaption(range: AgeRange(minAge: 20, maxAge: nil), thisYear: 2026))
    }

    func test_직접_입력_나이_범위는_고른_쪽만_보인다() {
        let summary = { MeetingFormFormat.ageSummary(option: .custom, range: AgeRange(minAge: $0, maxAge: $1)) }
        XCTAssertEqual(summary(28, 35), "28~35세")
        XCTAssertEqual(summary(28, nil), "28세~")
        XCTAssertEqual(summary(nil, 35), "~35세")
        XCTAssertEqual(summary(nil, nil), "직접 입력")
    }
}

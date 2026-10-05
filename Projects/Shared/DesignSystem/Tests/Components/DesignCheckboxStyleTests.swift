@testable import SharedDesignSystem
import XCTest

final class DesignCheckboxStyleTests: XCTestCase {
    func test_회색_체크_해제는_테두리_subtle만_있다() {
        let palette = DesignCheckboxStyleResolver.resolve(style: .check, isOn: false)
        XCTAssertNil(palette.fill)
        assertTheme(palette.border, dark: 0x7A7887FF, light: 0xB0AFB5FF)
        XCTAssertNil(palette.content)
        XCTAssertEqual(palette.diameter, 20)
    }

    func test_회색_체크_선택은_바탕_tertiary에_흰_체크다() {
        let palette = DesignCheckboxStyleResolver.resolve(style: .check, isOn: true)
        assertTheme(palette.fill, dark: 0xB0AFB5FF, light: 0x7A7887FF)
        XCTAssertNil(palette.border)
        assertTheme(palette.content, dark: 0xFFFFFFFF, light: 0xFFFFFFFF)
        XCTAssertEqual(palette.diameter, 20)
    }

    func test_검정_체크_해제는_회색_체크_해제와_같다() {
        XCTAssertEqual(
            DesignCheckboxStyleResolver.resolve(style: .vote, isOn: false),
            DesignCheckboxStyleResolver.resolve(style: .check, isOn: false)
        )
    }

    func test_검정_체크_선택은_바탕_neutral_1200에_흰_체크다() {
        let palette = DesignCheckboxStyleResolver.resolve(style: .vote, isOn: true)
        assertTheme(palette.fill, dark: 0x0E0E11FF, light: 0x0E0E11FF)
        XCTAssertNil(palette.border)
        assertTheme(palette.content, dark: 0xFFFFFFFF, light: 0xFFFFFFFF)
        XCTAssertEqual(palette.diameter, 20)
    }

    func test_번호_해제는_회색_반투명_바탕에_테두리_200이고_숫자가_없다() {
        let palette = DesignCheckboxStyleResolver.resolve(style: .order(2), isOn: false)
        assertTheme(palette.fill, dark: 0xAFAFAFB2, light: 0xAFAFAFB2)
        assertTheme(palette.border, dark: 0xEAEAEBFF, light: 0xEAEAEBFF)
        XCTAssertNil(palette.content)
        XCTAssertEqual(palette.diameter, 26)
    }

    func test_번호_선택은_바탕_primary_100에_숫자_neutral_1200이다() {
        let palette = DesignCheckboxStyleResolver.resolve(style: .order(2), isOn: true)
        assertTheme(palette.fill, dark: 0xFFF489FF, light: 0xFFF489FF)
        XCTAssertNil(palette.border)
        assertTheme(palette.content, dark: 0x0E0E11FF, light: 0x0E0E11FF)
        XCTAssertEqual(palette.diameter, 26)
    }

    func test_체크_아이콘은_14다() {
        XCTAssertEqual(DesignCheckboxMetrics.checkIconSize, 14)
    }
}

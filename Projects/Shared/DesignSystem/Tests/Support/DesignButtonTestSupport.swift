@testable import SharedDesignSystem
import XCTest

/// 버튼 한 상태의 바탕·내용 색(`0xRRGGBBAA` 다크·라이트)과 불투명도를 견준다.
/// 바탕이 없는 계열은 `background` 에 nil 을 넘긴다.
func assertPalette(
    _ palette: DesignButtonPalette,
    background: (dark: UInt32, light: UInt32)?,
    content: (dark: UInt32, light: UInt32),
    opacity: Double = 1,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    if let background {
        assertTheme(palette.background, dark: background.dark, light: background.light, file: file, line: line)
    } else {
        XCTAssertNil(palette.background, "바탕", file: file, line: line)
    }
    assertTheme(palette.content, dark: content.dark, light: content.light, file: file, line: line)
    XCTAssertEqual(palette.opacity, opacity, "불투명도", file: file, line: line)
}

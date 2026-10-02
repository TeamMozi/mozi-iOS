@testable import SharedDesignSystem
import UIKit
import XCTest

/// 색을 `0xRRGGBBAA` 로 바꾼다. 기대값을 Figma 표의 16진 값 그대로 적으려고 쓴다.
func rgba(_ token: TokenColor) -> UInt32 {
    token.hexRGB << 8 | UInt32((token.alpha * 255).rounded())
}

/// 주어진 모드의 trait 으로 풀어 낸 색을 `0xRRGGBBAA` 로 바꾼다.
@MainActor
func rgba(_ color: UIColor, in style: UIUserInterfaceStyle) -> UInt32 {
    let resolved = color.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return [red, green, blue, alpha].reduce(UInt32(0)) { packed, component in
        packed << 8 | UInt32((component * 255).rounded())
    }
}

/// 다크·라이트 쌍을 `0xRRGGBBAA` 두 값과 견준다.
func assertTheme(
    _ theme: ThemedColor?,
    dark: UInt32,
    light: UInt32,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard let theme else {
        XCTFail("색이 없다", file: file, line: line)
        return
    }
    XCTAssertEqual(rgba(theme.dark), dark, "dark", file: file, line: line)
    XCTAssertEqual(rgba(theme.light), light, "light", file: file, line: line)
}

import SwiftUI
import UIKit

/// 한 모드의 색 하나. `hexRGB` 는 `0xRRGGBB`, `alpha` 는 0~1 이다.
struct TokenColor: Equatable, Sendable {
    let hexRGB: UInt32
    let alpha: Double

    init(hexRGB: UInt32, alpha: Double = 1.0) {
        self.hexRGB = hexRGB
        self.alpha = alpha
    }

    var color: Color {
        Color(hex: hexRGB, alpha: alpha)
    }

    var uiColor: UIColor {
        UIColor(
            red: CGFloat((hexRGB >> 16) & 0xFF) / 255,
            green: CGFloat((hexRGB >> 8) & 0xFF) / 255,
            blue: CGFloat(hexRGB & 0xFF) / 255,
            alpha: CGFloat(alpha)
        )
    }
}

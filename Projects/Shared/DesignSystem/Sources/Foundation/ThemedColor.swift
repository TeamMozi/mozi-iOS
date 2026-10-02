import SwiftUI
import UIKit

/// Figma 의미 색 하나. 다크·라이트 두 모드의 색 쌍이다.
struct ThemedColor: Equatable, Sendable {
    let dark: TokenColor
    let light: TokenColor

    /// 라이트 trait 에서만 라이트 값이다. 다크와 모드가 정해지지 않은 trait 은 다크 값이다.
    func resolved(for style: UIUserInterfaceStyle) -> TokenColor {
        style == .light ? light : dark
    }

    /// 기기 모드를 따라 바뀌는 색.
    var color: Color {
        let theme = self
        return Color(uiColor: UIColor { traits in
            theme.resolved(for: traits.userInterfaceStyle).uiColor
        })
    }
}

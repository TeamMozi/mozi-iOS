import SwiftUI
import UIKit

/// Figma 의미 색 하나. 다크·라이트 두 모드의 색 쌍이다.
struct ThemedColor: Equatable, Sendable {
    let dark: TokenColor
    let light: TokenColor

    /// 시안이 의미 색 대신 원시 색을 바로 쓰는 자리. 두 모드에 같은 색이다.
    static func fixed(_ token: TokenColor) -> ThemedColor {
        ThemedColor(dark: token, light: token)
    }

    /// 라이트 trait 에서만 라이트 값이다. 다크와 모드가 정해지지 않은 trait 은 다크 값이다.
    func resolved(for style: UIUserInterfaceStyle) -> TokenColor {
        style == .light ? light : dark
    }

    /// 기기 모드를 따라 바뀌는 UIKit 색. UIKit 글자 칸이 쓴다.
    var uiColor: UIColor {
        let theme = self
        return UIColor { traits in
            theme.resolved(for: traits.userInterfaceStyle).uiColor
        }
    }

    /// 기기 모드를 따라 바뀌는 색.
    var color: Color {
        Color(uiColor: uiColor)
    }
}

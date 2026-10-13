import SwiftUI
import UIKit

/// 줄 칸(`DesignTextFieldStyle.row(text:)` · `DesignTextAreaStyle.row(height:showsCounter:text:)`)의 글자 모양과 색.
/// 입력 글자와 placeholder 를 따로 준다. 색을 비우면 지금 색(입력 글자는 입력 중 primary·그 밖 secondary, placeholder 는 subtle)이다.
/// 색을 넘기면 입력 전·중·뒤와 상관없이 그 색이다.
public struct DesignRowText: Equatable, Sendable {
    public let textStyle: TextStyle
    public let textColor: Color?
    public let placeholderStyle: TextStyle
    public let placeholderColor: Color?

    public init(
        textStyle: TextStyle = TextStyle.ds.body.regular,
        textColor: Color? = nil,
        placeholderStyle: TextStyle = TextStyle.ds.body.regular,
        placeholderColor: Color? = nil
    ) {
        self.textStyle = textStyle
        self.textColor = textColor
        self.placeholderStyle = placeholderStyle
        self.placeholderColor = placeholderColor
    }

    /// 지금 모양. Body/Regular 와 상태별 색.
    public static let standard = DesignRowText()

    func textColor(fallback: ThemedColor) -> DesignInputColor {
        textColor.map(DesignInputColor.custom) ?? .themed(fallback)
    }

    func placeholderColor(fallback: ThemedColor) -> DesignInputColor {
        placeholderColor.map(DesignInputColor.custom) ?? .themed(fallback)
    }
}

/// UIKit 글자 칸에 거는 색. 디자인 시스템 쌍이거나 쓰는 쪽이 넘긴 `Color`(`Color.ds` 는 기기 모드를 따른다)다.
enum DesignInputColor: Equatable, Sendable {
    case themed(ThemedColor)
    case custom(Color)

    var uiColor: UIColor {
        switch self {
        case let .themed(theme):
            theme.uiColor
        case let .custom(color):
            UIColor(color)
        }
    }
}

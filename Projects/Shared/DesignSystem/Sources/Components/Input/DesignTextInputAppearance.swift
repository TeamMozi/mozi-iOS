import UIKit

/// UIKit 글자 칸의 글자·placeholder·커서·안쪽 여백. 색은 다크·라이트 쌍이다.
struct DesignTextInputAppearance: Equatable, Sendable {
    let textStyle: TextStyle
    let textColor: ThemedColor
    let placeholder: String
    let placeholderStyle: TextStyle
    let placeholderColor: ThemedColor
    let tint: ThemedColor
    let accessibilityLabel: String
    /// 여러 줄 칸의 글자 둘레(`textContainerInset`). 한 줄 칸은 쓰지 않는다.
    let textInsets: UIEdgeInsets

    /// 입력한 글자의 속성. 줄 높이는 여러 줄 칸에서만 건다.
    func textAttributes(includesLineHeight: Bool) -> [NSAttributedString.Key: Any] {
        Self.attributes(style: textStyle, color: textColor, includesLineHeight: includesLineHeight)
    }

    /// placeholder 의 속성. 여러 줄 칸은 입력 글자와 같은 줄 높이를 걸어 같은 자리에 그린다.
    func placeholderAttributes(includesLineHeight: Bool) -> [NSAttributedString.Key: Any] {
        Self.attributes(style: placeholderStyle, color: placeholderColor, includesLineHeight: includesLineHeight)
    }

    private static func attributes(
        style: TextStyle,
        color: ThemedColor,
        includesLineHeight: Bool
    ) -> [NSAttributedString.Key: Any] {
        var result: [NSAttributedString.Key: Any] = [
            .font: style.uiFont,
            .kern: style.letterSpacing,
            .foregroundColor: color.uiColor,
        ]
        if includesLineHeight {
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = style.lineHeight
            paragraph.maximumLineHeight = style.lineHeight
            result[.paragraphStyle] = paragraph
        }
        return result
    }
}

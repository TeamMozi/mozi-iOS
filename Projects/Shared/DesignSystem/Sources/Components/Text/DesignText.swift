import SwiftUI

public struct DesignText: View {
    private let text: String
    private let style: TextStyle
    private let color: Color
    private let alignment: TextAlignment
    private let lineLimit: Int?

    public init(
        _ text: String,
        style: TextStyle,
        color: Color = Color.ds.text.neutral.white,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil
    ) {
        self.text = text
        self.style = style
        self.color = color
        self.alignment = alignment
        self.lineLimit = lineLimit
    }

    public var body: some View {
        Text(text)
            .font(style.font)
            .kerning(style.letterSpacing)
            .lineSpacing(style.additionalLineSpacing)
            .foregroundStyle(color)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
    }
}

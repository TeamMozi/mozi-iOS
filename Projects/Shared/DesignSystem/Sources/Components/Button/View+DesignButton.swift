import SwiftUI

extension View {
    /// 버튼 글자에 글자 스타일의 글꼴과 자간을 건다.
    /// 높이가 고정된 버튼은 버튼 높이가 상자를 정하므로 줄 간격과 위아래 여백은 걸지 않는다.
    func designButtonText(_ style: TextStyle) -> some View {
        font(style.font)
            .kerning(style.letterSpacing)
            .lineLimit(1)
    }

    /// 높이가 고정되지 않은 버튼(액션)의 글자. `DesignText` 처럼 글자 상자를 줄 높이에 맞춘다.
    func designButtonLineBoxText(_ style: TextStyle) -> some View {
        designButtonText(style)
            .lineSpacing(style.additionalLineSpacing)
            .padding(.vertical, style.lineBoxVerticalPadding)
    }

    /// 색이 있을 때만 모양대로 바탕을 칠한다. 바탕이 없는 계열은 nil 을 넘긴다.
    func designButtonBackground(_ color: ThemedColor?, in shape: some Shape) -> some View {
        background {
            if let color {
                shape.fill(color.color)
            }
        }
    }
}

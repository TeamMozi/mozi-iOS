import SwiftUI

/// 헤더 배경 둘. 투명은 시스템 기본이고 스크롤하면 시스템 가장자리 효과가 난다(Figma 「Gradient」 를 대신한다).
/// 채움은 `fill/neutral/default` 다.
public enum DesignHeaderBackground: Sendable {
    case transparent
    case filled

    var fill: ThemedColor? {
        switch self {
        case .transparent: nil
        case .filled: SemanticColor.fill.neutral.default
        }
    }
}

public extension View {
    /// `NavigationStack` 안 화면에 건다. 시스템 헤더의 배경을 고른다.
    @ViewBuilder
    func designHeaderBackground(_ background: DesignHeaderBackground) -> some View {
        if let fill = background.fill {
            toolbarBackground(fill.color, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        } else {
            self
        }
    }
}

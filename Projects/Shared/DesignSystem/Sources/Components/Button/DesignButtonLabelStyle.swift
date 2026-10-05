import SwiftUI

/// 아이콘이 글자 어느 쪽에 놓이는지.
enum DesignButtonIconPlacement: Equatable, Sendable {
    case leading
    case trailing
}

/// 버튼 안 아이콘과 글자를 가로로 놓는다. 아이콘은 정한 크기 상자에 비율을 지켜 맞춘다.
/// 아이콘이 늘어나려면 `Button(_:icon:)` 처럼 `resizable()` 로 넘겨야 한다.
struct DesignButtonLabelStyle: LabelStyle {
    let iconSize: CGFloat
    let spacing: CGFloat
    let placement: DesignButtonIconPlacement

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            if placement == .leading {
                sizedIcon(configuration.icon)
            }
            configuration.title
            if placement == .trailing {
                sizedIcon(configuration.icon)
            }
        }
    }

    private func sizedIcon(_ icon: Configuration.Icon) -> some View {
        icon
            .scaledToFit()
            .frame(width: iconSize, height: iconSize)
    }
}

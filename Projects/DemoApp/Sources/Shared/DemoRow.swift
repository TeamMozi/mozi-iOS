import SharedDesignSystem
import SwiftUI

/// 높이 52 의 목록 줄. 왼쪽 글과 오른쪽 끝 내용.
struct DemoRow<Leading: View, Trailing: View>: View {
    @ViewBuilder let leading: Leading
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: CGFloat.ds.spacing.md) {
            leading
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, CGFloat.ds.spacing.lg)
        .frame(height: DemoRowLayout.height)
        .contentShape(Rectangle())
    }
}

private enum DemoRowLayout {
    static let height: CGFloat = 52
}

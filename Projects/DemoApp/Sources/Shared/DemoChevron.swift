import SharedDesignSystem
import SwiftUI

/// 줄 끝 오른쪽 화살표.
struct DemoChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(TextStyle.ds.caption2.semiBold.font)
            .foregroundStyle(Color.ds.text.neutral.subtle)
            .accessibilityHidden(true)
    }
}

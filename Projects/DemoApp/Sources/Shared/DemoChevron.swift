import SwiftUI

/// 줄 끝 오른쪽 화살표.
struct DemoChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(DemoPalette.chevron)
            .accessibilityHidden(true)
    }
}

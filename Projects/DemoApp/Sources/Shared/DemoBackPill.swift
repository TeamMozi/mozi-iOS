import SharedDesignSystem
import SwiftUI

/// 왼쪽 위 알약 모양 뒤로 버튼.
struct DemoBackPill: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DemoBackPillLayout.iconSpacing) {
                Image(systemName: "chevron.left")
                    .font(TextStyle.ds.caption2.semiBold.font)
                DesignText(title, style: TextStyle.ds.subtext.medium, color: Color.ds.text.neutral.primary)
            }
            .foregroundStyle(Color.ds.text.neutral.primary)
            .padding(.leading, DemoBackPillLayout.leadingPadding)
            .padding(.trailing, DemoBackPillLayout.trailingPadding)
            .frame(minHeight: DemoBackPillLayout.minHeight)
            .background(Color.ds.fill.neutral.subtle, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private enum DemoBackPillLayout {
    static let iconSpacing: CGFloat = 6
    static let leadingPadding: CGFloat = 10
    static let trailingPadding: CGFloat = 14
    static let minHeight: CGFloat = 44
}

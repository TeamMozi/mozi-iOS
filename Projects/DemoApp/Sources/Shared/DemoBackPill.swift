import SharedDesignSystem
import SwiftUI

/// 왼쪽 위 알약 모양 뒤로 버튼.
struct DemoBackPill: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                DesignText(title, style: TextStyle.ds.label.medium14Medium, color: Color.ds.text.neutral.lighter)
            }
            .foregroundStyle(Color.ds.text.neutral.lighter)
            .padding(.leading, 10)
            .padding(.trailing, 14)
            .frame(minHeight: 44)
            .background(Color.ds.background.grayDarker, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

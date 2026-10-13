import SharedDesignSystem
import SwiftUI

/// 아래쪽 구간들의 제목 줄. Figma `Section Title`. 숫자와 「더보기 >」 는 구간마다 켠다.
struct MeetingDetailSectionTitle: View {
    let title: String
    var count: Int?
    var onMore: (@MainActor () -> Void)?

    var body: some View {
        HStack(spacing: CGFloat.ds.spacing.xs) {
            DesignText(title, style: TextStyle.ds.body.semiBold, color: Color.ds.text.accent.default)
            if let count {
                DesignText("\(count)", style: TextStyle.ds.body.semiBold, color: Color.ds.text.neutral.subtle)
            }
            Spacer(minLength: 0)
            if let onMore {
                Button("더보기", icon: Image.ds.icon.chevron.right, action: onMore)
                    .buttonStyle(.textButton(.neutral))
            }
        }
    }
}

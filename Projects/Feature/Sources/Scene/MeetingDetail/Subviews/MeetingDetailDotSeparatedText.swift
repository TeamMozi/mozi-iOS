import SharedDesignSystem
import SwiftUI

/// 「34회차 · 148명 참여 · 345개 모먼트」 처럼 낱말 사이에 2pt 점을 그리는 한 줄. 점은 글자와 같은 색이다.
/// 점은 VoiceOver 가 읽지 못하므로 「 · 」 로 이은 문장을 라벨로 받아 한 문장으로 읽힌다.
struct MeetingDetailDotSeparatedText: View {
    let parts: [String]
    let accessibilityLabel: String
    let style: TextStyle
    let color: Color

    var body: some View {
        HStack(spacing: CGFloat.ds.spacing.xs) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                if index > 0 {
                    Circle()
                        .fill(color)
                        .frame(
                            width: MeetingDetailDotSeparatedLayout.dotSize,
                            height: MeetingDetailDotSeparatedLayout.dotSize
                        )
                }
                DesignText(part, style: style, color: color, lineLimit: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
}

private enum MeetingDetailDotSeparatedLayout {
    static let dotSize: CGFloat = 2
}

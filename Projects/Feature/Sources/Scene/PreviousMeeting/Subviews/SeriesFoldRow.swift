import Domain
import SharedDesignSystem
import SwiftUI

/// 「시리즈별」 의 시리즈 접힘 줄. 누르면 그 시리즈의 회차 카드를 펼치고 접는다.
struct SeriesFoldRow: View {
    let hosted: HostedSeries
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                HStack(spacing: CGFloat.ds.spacing.xs) {
                    (isExpanded ? Image.ds.icon.chevron.down : Image.ds.icon.chevron.right)
                        .iconSize(CGFloat.ds.iconSize._14)
                        .foregroundStyle(isExpanded ? Color.ds.text.accent.highlight : Color.ds.text.neutral.faint)
                    DesignText(hosted.series.title, style: TextStyle.ds.caption1.semiBold, lineLimit: 1)
                }
                .frame(height: SeriesFoldRowLayout.lineHeight, alignment: .bottom)
                HStack(spacing: CGFloat.ds.spacing.xs) {
                    DesignText(
                        "총 \(hosted.series.episodeCount)회차",
                        style: TextStyle.ds.caption1.medium,
                        color: Color.ds.text.neutral.tertiary,
                        lineLimit: 1
                    )
                    if let last = hosted.recentMeetings.first {
                        Circle()
                            .fill(Color.ds.text.neutral.tertiary)
                            .frame(width: SeriesFoldRowLayout.dotSize, height: SeriesFoldRowLayout.dotSize)
                        DesignText(
                            "마지막 모임 \(PreviousMeetingFormat.date(last.startAt))",
                            style: TextStyle.ds.caption1.medium,
                            color: Color.ds.text.neutral.tertiary,
                            lineLimit: 1
                        )
                    }
                }
                .frame(height: SeriesFoldRowLayout.lineHeight)
                .padding(.leading, SeriesFoldRowLayout.textLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isExpanded ? .isSelected : [])
    }
}

private enum SeriesFoldRowLayout {
    /// 이름 줄과 요약 줄의 높이
    static let lineHeight: CGFloat = 20
    /// 요약 줄 들여쓰기. 아이콘 14 + 사이 4 로 이름 글자와 맞춘다
    static let textLeading: CGFloat = 18
    /// 「총 N회차」 와 「마지막 모임」 사이 점
    static let dotSize: CGFloat = 2
}

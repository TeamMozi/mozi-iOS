import Domain
import SharedDesignSystem
import SwiftUI

/// 모임장 프로필. 개최·참여 기록이 없으면 그 줄을 그리지 않는다.
struct MeetingDetailHostSection: View {
    let host: MeetingHost

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            MeetingDetailSectionTitle(title: "모임장")
            HStack(spacing: CGFloat.ds.spacing.md) {
                DesignAvatar(
                    host.profileImageURL,
                    diameter: MeetingDetailHostLayout.avatarSide,
                    shape: .roundedRectangle(cornerRadius: CGFloat.ds.radius._8)
                )
                VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: MeetingDetailHostLayout.crownSpacing) {
                            DesignText(host.nickname, style: TextStyle.ds.headline.semiBold, lineLimit: 1)
                            Image.ds.symbol.crown
                                .font(TextStyle.ds.caption2.semiBold.font)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.ds.text.neutral.faint)
                                .accessibilityHidden(true)
                        }
                        .frame(height: MeetingDetailHostLayout.nameRowHeight)
                        if let introduction = host.introduction, !introduction.isEmpty {
                            DesignText(
                                introduction,
                                style: TextStyle.ds.subtext.regular,
                                color: Color.ds.text.neutral.tertiary,
                                lineLimit: 1
                            )
                        }
                    }
                    if let record = MeetingDisplayFormat.hostRecordParts(
                        hostedCount: host.hostedCount,
                        participatedCount: host.participatedCount
                    ), let recordLabel = MeetingDisplayFormat.hostRecord(
                        hostedCount: host.hostedCount,
                        participatedCount: host.participatedCount
                    ) {
                        MeetingDetailDotSeparatedText(
                            parts: record,
                            accessibilityLabel: recordLabel,
                            style: TextStyle.ds.caption1.regular,
                            color: Color.ds.text.neutral.faint
                        )
                    }
                }
            }
            .padding(.vertical, CGFloat.ds.spacing.sm)
            .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CGFloat.ds.layout.margin)
    }
}

private enum MeetingDetailHostLayout {
    static let avatarSide: CGFloat = 76
    static let crownSpacing: CGFloat = 2
    static let nameRowHeight: CGFloat = 24
}

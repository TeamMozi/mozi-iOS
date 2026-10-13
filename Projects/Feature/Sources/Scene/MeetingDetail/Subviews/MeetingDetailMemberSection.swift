import Domain
import SharedDesignSystem
import SwiftUI

/// 모임장을 뺀 확정 멤버. 「더보기 >」 는 아직 보이기만 한다.
struct MeetingDetailMemberSection: View {
    let members: [MeetingMember]

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            MeetingDetailSectionTitle(title: "참여 멤버", count: members.count, onMore: {})
                .padding(.horizontal, CGFloat.ds.layout.margin)
            if members.isEmpty {
                DesignText(
                    "아직 참여한 멤버가 없어요",
                    style: TextStyle.ds.body.regular,
                    color: Color.ds.text.neutral.subtle
                )
                .padding(.horizontal, CGFloat.ds.layout.margin)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: CGFloat.ds.spacing.md) {
                        ForEach(members, id: \.userID) { member in
                            memberItem(member)
                        }
                    }
                    .padding(.vertical, CGFloat.ds.spacing.sm)
                    .padding(.horizontal, CGFloat.ds.layout.margin)
                }
            }
        }
    }

    private func memberItem(_ member: MeetingMember) -> some View {
        VStack(spacing: CGFloat.ds.spacing.sm) {
            DesignAvatar(member.profileImageURL, diameter: MeetingDetailMemberLayout.itemWidth)
            DesignText(
                member.nickname,
                style: TextStyle.ds.subtext.regular,
                color: Color.ds.text.neutral.secondary,
                alignment: .center,
                lineLimit: 1
            )
            .frame(width: MeetingDetailMemberLayout.itemWidth, height: MeetingDetailMemberLayout.nameHeight)
        }
    }
}

private enum MeetingDetailMemberLayout {
    static let itemWidth: CGFloat = 56
    static let nameHeight: CGFloat = 24
}

import Domain
import SharedDesignSystem
import SwiftUI

/// 포스터, 제목, 날짜·장소.
struct WidgetHeader: View {
    let meeting: Meeting

    var body: some View {
        VStack(spacing: WidgetHeaderLayout.bioSpacing) {
            poster
            VStack(spacing: WidgetHeaderLayout.titleSpacing) {
                DesignText(meeting.title, style: TextStyle.ds.title3.semiBold, alignment: .center)
                DesignText(
                    MeetingDisplayFormat.widgetSubtitle(startAt: meeting.startAt, placeName: meeting.place.name),
                    style: TextStyle.ds.caption1.medium,
                    color: Color.ds.text.neutral.secondary,
                    alignment: .center
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var poster: some View {
        AsyncImage(url: meeting.posterURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                // 상세 포스터와 같은 기본 이미지
                ZStack {
                    Color.ds.fill.neutral.subtle
                    Image.ds.brand.logo
                }
            }
        }
        .frame(width: WidgetHeaderLayout.posterWidth, height: WidgetHeaderLayout.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._16, style: .continuous))
        .accessibilityHidden(true)
    }
}

/// 홈·채팅·멤버·필름 타일. 멤버만 누를 수 있고, 나머지 셋은 그림만 그린다.
struct WidgetTiles: View {
    let isMemberGridShown: Bool
    let onMembers: () -> Void

    var body: some View {
        HStack(spacing: CGFloat.ds.spacing.md) {
            WidgetTile(icon: Image.ds.icon.home.filled, isSelected: false)
            WidgetTile(icon: Image.ds.icon.chat.filled, isSelected: false)
            Button { onMembers() } label: {
                WidgetTile(icon: Image.ds.icon.people.filled, isSelected: isMemberGridShown)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("멤버")
            .accessibilityAddTraits(isMemberGridShown ? .isSelected : [])
            WidgetTile(icon: Image.ds.icon.video.filled, isSelected: false)
        }
    }
}

private struct WidgetTile: View {
    let icon: Image
    let isSelected: Bool

    var body: some View {
        icon
            .iconSize(CGFloat.ds.iconSize._24)
            .foregroundStyle(Color.ds.text.neutral.primary)
            .frame(width: WidgetHeaderLayout.tileSide, height: WidgetHeaderLayout.tileSide)
            .background(
                isSelected ? Color.ds.fill.neutral.muted : Color.ds.fill.neutral.subtle,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
            )
    }
}

/// 모임장을 뺀 확정 멤버 사진 격자와 「멤버 전체보기 >」.
struct WidgetMemberGrid: View {
    let members: [MeetingMember]
    let onShowAll: () -> Void

    private let columns = Array(
        repeating: GridItem(.fixed(WidgetHeaderLayout.photoSide), spacing: WidgetHeaderLayout.photoSpacing),
        count: WidgetHeaderLayout.columnCount
    )

    var body: some View {
        VStack(spacing: CGFloat.ds.spacing.md) {
            LazyVGrid(columns: columns, spacing: WidgetHeaderLayout.photoSpacing) {
                ForEach(members, id: \.userID) { member in
                    photo(member.profileImageURL)
                }
            }
            Button("멤버 전체보기", icon: Image.ds.icon.chevron.right) { onShowAll() }
                .buttonStyle(.textButton(.neutral))
        }
        .padding(.horizontal, CGFloat.ds.spacing.lg)
    }

    private func photo(_ url: URL?) -> some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Color.ds.fill.neutral.subtle
            }
        }
        .frame(width: WidgetHeaderLayout.photoSide, height: WidgetHeaderLayout.photoSide)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._6, style: .continuous))
        .accessibilityHidden(true)
    }
}

private enum WidgetHeaderLayout {
    static let bioSpacing: CGFloat = 14
    static let titleSpacing: CGFloat = 6
    static let posterWidth: CGFloat = 140
    static let posterHeight: CGFloat = 175
    static let tileSide: CGFloat = 44
    static let photoSide: CGFloat = 72
    static let photoSpacing: CGFloat = 6
    static let columnCount = 4
}

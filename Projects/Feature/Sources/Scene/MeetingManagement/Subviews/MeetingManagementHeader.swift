import Domain
import SharedDesignSystem
import SwiftUI

/// 사이드바 맨 위. 포스터와 제목·일정·모집 상태 칩.
struct MeetingManagementHeader: View {
    let meeting: Meeting
    let isEnded: Bool
    let onPosterEdit: () -> Void
    let onStatusSelect: (MeetingStatus) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: CGFloat.ds.spacing.lg) {
            poster
            information
        }
        .padding(MeetingManagementHeaderLayout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var poster: some View {
        Button(action: onPosterEdit) {
            ZStack {
                // 포스터가 없으면 상세의 기본 포스터와 같은 모양(바탕 + 로고)을 그린다.
                Color.ds.fill.neutral.subtle
                Image.ds.brand.logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: MeetingManagementHeaderLayout.placeholderLogoWidth)
                if let url = meeting.posterURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                }
                // 시안은 두 모드 모두 검정 60% 덮개(`overlay/dark/60`)에 흰 글자다.
                Color.ds.overlay.dim._60
                    .environment(\.colorScheme, .dark)
                VStack(spacing: MeetingManagementHeaderLayout.posterLabelSpacing) {
                    DesignText(
                        "포스터 편집",
                        style: TextStyle.ds.caption1.semiBold,
                        color: Color.ds.text.neutral.inverse,
                        alignment: .center
                    )
                    .environment(\.colorScheme, .light)
                    Image.ds.icon.questionAlt.filled
                        .iconSize(CGFloat.ds.iconSize._24)
                        .foregroundStyle(Color.ds.text.neutral.primary)
                }
            }
            .frame(width: MeetingManagementHeaderLayout.posterWidth, height: MeetingManagementHeaderLayout.posterHeight)
            .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // 시안은 글 묶음과 상태 칩을 칸 위에서 정한 자리에 놓는다. 제목이 한 줄이어도 칩 자리는 그대로다.
    private var information: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                DesignText(meeting.title, style: TextStyle.ds.title3.semiBold, lineLimit: 2)
                DesignText(
                    MeetingDisplayFormat.managementSubtitle(startAt: meeting.startAt, address: meeting.place.address),
                    style: TextStyle.ds.caption1.regular,
                    color: Color.ds.text.neutral.subtle,
                    lineLimit: 1
                )
                .frame(height: MeetingManagementHeaderLayout.subtitleHeight)
            }
            .padding(.top, MeetingManagementHeaderLayout.textTop)
            DesignStatusMenu(
                status: meeting.status.recruitStatus,
                options: MeetingManagementFeature.selectableStatuses(from: meeting.status).map(\.recruitStatus)
            ) { onStatusSelect($0.meetingStatus) }
                .disabled(isEnded)
                .padding(.top, MeetingManagementHeaderLayout.statusTop)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: MeetingManagementHeaderLayout.posterHeight, alignment: .topLeading)
    }
}

/// 사이드바의 행 묶음 카드. 행 사이에 구분선을 긋는다.
struct MeetingManagementGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { subviews in
                // 시안처럼 구분선(`border/neutral/30`)은 행 맨 아래 1pt 에 겹쳐 그린다. 행 높이(54)에 더하지 않는다.
                ForEach(subviews) { subview in
                    subview
                        .overlay(alignment: .bottom) {
                            if subview.id != subviews.last?.id {
                                Rectangle()
                                    .fill(Color.ds.border.neutral._30)
                                    .frame(height: CGFloat.ds.border.thin)
                                    .padding(.leading, MeetingManagementHeaderLayout.separatorLeading)
                                    .padding(.trailing, CGFloat.ds.spacing.lg)
                            }
                        }
                }
            }
        }
        // 행 묶음 바탕은 시안 값 `overlay/gray/10`(Figma 사이드바 `2798:100802` 의 Form Group 채움)이다.
        .background(
            Color.ds.overlay.gray._10,
            in: RoundedRectangle(cornerRadius: MeetingManagementHeaderLayout.groupRadius, style: .continuous)
        )
    }
}

private extension MeetingStatus {
    var recruitStatus: DesignRecruitStatus {
        switch self {
        case .recruiting: .recruiting
        case .closed: .closed
        case .ended: .ended
        }
    }
}

private extension DesignRecruitStatus {
    var meetingStatus: MeetingStatus {
        switch self {
        case .recruiting: .recruiting
        case .closed: .closed
        case .ended: .ended
        }
    }
}

private enum MeetingManagementHeaderLayout {
    static let padding: CGFloat = 10
    static let posterWidth: CGFloat = 114
    static let posterHeight: CGFloat = 152
    static let posterLabelSpacing: CGFloat = 10
    /// 상세 기본 포스터(폭 264 에 로고 150)와 같은 비율로 줄인 폭.
    static let placeholderLogoWidth: CGFloat = 65
    static let textTop: CGFloat = 19
    static let subtitleHeight: CGFloat = 28
    static let statusTop: CGFloat = 105
    static let separatorLeading: CGFloat = 14
    static let groupRadius: CGFloat = 26
}

import Domain
import SharedDesignSystem
import SwiftUI

/// 스냅 포인트 한 줄. 보내지 않은 줄은 「알림」 버튼을, 보낸 줄은 보낸 시각과 참여 멤버를 그린다.
/// 참여 멤버 줄은 `participantCount` 가 있을 때만 그린다.
struct WidgetSnapPointRow: View {
    let snapPoint: SnapPoint
    let members: [MeetingMember]
    let participantCount: Int?
    let canNotify: Bool
    let isSending: Bool
    let onNotify: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: WidgetSnapPointRowLayout.spacing) {
            number
            VStack(alignment: .leading, spacing: WidgetSnapPointRowLayout.contentSpacing) {
                VStack(alignment: .leading, spacing: WidgetSnapPointRowLayout.textSpacing) {
                    DesignText(snapPoint.name, style: TextStyle.ds.headline.semiBold)
                    DesignText(
                        snapPoint.notificationMessage,
                        style: TextStyle.ds.caption1.regular,
                        color: Color.ds.text.neutral.tertiary
                    )
                }
                .padding(.horizontal, WidgetSnapPointRowLayout.textInset)
                if let count = participantCount {
                    participants(count: count)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
        }
        .padding(.vertical, WidgetSnapPointRowLayout.verticalInset)
    }

    private var number: some View {
        DesignText(
            "\(snapPoint.order)",
            style: TextStyle.ds.title3.semiBold,
            color: snapPoint.isSent ? Color.ds.text.neutral.subtle : Color.ds.button.label.main.default
        )
            .frame(width: WidgetSnapPointRowLayout.numberDiameter, height: WidgetSnapPointRowLayout.numberDiameter)
            .background(
                snapPoint.isSent ? Color.ds.fill.neutral.raised : Color.ds.button.background.main.default,
                in: Circle()
            )
            // 시안은 보내기 전 번호를 42pt 칸 아래에 붙여 보낸 줄보다 2pt 내려 그린다
            .frame(
                width: WidgetSnapPointRowLayout.numberWidth,
                height: snapPoint.isSent
                    ? WidgetSnapPointRowLayout.numberDiameter
                    : WidgetSnapPointRowLayout.numberWidth,
                alignment: .bottom
            )
            .accessibilityHidden(true)
    }

    private func participants(count: Int) -> some View {
        HStack(spacing: WidgetSnapPointRowLayout.participantSpacing) {
            HStack(spacing: WidgetSnapPointRowLayout.avatarOverlap) {
                ForEach(members.prefix(WidgetSnapPointRowLayout.avatarCount), id: \.userID) { member in
                    DesignAvatar(member.profileImageURL, diameter: WidgetSnapPointRowLayout.avatarDiameter)
                        .avatarRing()
                }
                Image.ds.icon.moreHorizontal.filled
                    .iconSize(CGFloat.ds.iconSize._14)
                    .foregroundStyle(Color.ds.border.accent.darker)
                    .frame(
                        width: WidgetSnapPointRowLayout.avatarDiameter,
                        height: WidgetSnapPointRowLayout.avatarDiameter
                    )
                    .background(Color.ds.fill.neutral.strong, in: Circle())
                    .avatarRing()
                    .accessibilityHidden(true)
            }
            DesignText(
                MeetingDisplayFormat.participants(count),
                style: TextStyle.ds.caption2.medium,
                color: Color.ds.text.neutral.subtle
            )
        }
        .frame(height: WidgetSnapPointRowLayout.avatarDiameter)
    }

    @ViewBuilder
    private var trailing: some View {
        if let sentAt = snapPoint.sentAt {
            DesignText(
                MeetingDisplayFormat.sentTime(sentAt),
                style: TextStyle.ds.headline.regular,
                color: Color.ds.text.neutral.faint
            )
            .frame(width: WidgetSnapPointRowLayout.trailingWidth, height: WidgetSnapPointRowLayout.trailingHeight)
        } else {
            notifyButton
                .frame(
                    width: WidgetSnapPointRowLayout.trailingWidth,
                    height: WidgetSnapPointRowLayout.trailingHeight,
                    alignment: .bottom
                )
        }
    }

    private var notifyButton: some View {
        Button { onNotify() } label: {
            ZStack {
                DesignText(
                    "알림",
                    style: TextStyle.ds.headline.semiBold,
                    color: canNotify ? Color.ds.text.neutral.primary : Color.ds.text.neutral.faint
                )
                .opacity(isSending ? 0 : 1)
                if isSending {
                    ProgressView()
                }
            }
            // 시안 버튼은 55×37 이고 「알림」 을 가운데 둔다. 좌우 여백 14 로 그리면 글자가 「알…」 로 잘린다
            .frame(width: WidgetSnapPointRowLayout.trailingWidth, height: WidgetSnapPointRowLayout.buttonHeight)
            .background(
                Color.ds.fill.neutral.subtle,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._8, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(!canNotify)
        .accessibilityLabel("\(snapPoint.name) 알림 보내기")
    }
}

private extension View {
    /// 겹친 사진 사이를 바탕색 테두리로 가른다.
    func avatarRing() -> some View {
        padding(CGFloat.ds.border.thick)
            .background(Color.ds.border.neutral._0, in: Circle())
            .padding(-CGFloat.ds.border.thick)
    }
}

private enum WidgetSnapPointRowLayout {
    static let spacing: CGFloat = 10
    static let verticalInset: CGFloat = 10
    static let contentSpacing: CGFloat = 14
    static let textSpacing: CGFloat = 2
    static let textInset: CGFloat = 2
    static let numberWidth: CGFloat = 42
    static let numberDiameter: CGFloat = 40
    static let participantSpacing: CGFloat = 6
    static let avatarOverlap: CGFloat = -6
    static let avatarDiameter: CGFloat = 27
    static let avatarCount = 3
    static let trailingWidth: CGFloat = 55
    static let trailingHeight: CGFloat = 42
    static let buttonHeight: CGFloat = 37
}

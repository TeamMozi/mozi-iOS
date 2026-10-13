import Domain
import SharedDesignSystem
import SwiftUI

/// 제목, 상태·일시·인원 한 줄, 정보 칩 넷, 장소 카드.
struct MeetingDetailSummarySection: View {
    let meeting: Meeting

    var body: some View {
        VStack(spacing: CGFloat.ds.spacing.lg) {
            VStack(spacing: CGFloat.ds.spacing.lg) {
                VStack(spacing: MeetingDetailSummaryLayout.titleSpacing) {
                    DesignText(meeting.title, style: TextStyle.ds.title2.bold, alignment: .center)
                        .padding(.horizontal, MeetingDetailSummaryLayout.titleInset)
                    statusLine
                }
                infoRow
            }
            MeetingDetailPlaceCard(place: meeting.place)
        }
        .padding(.horizontal, CGFloat.ds.layout.margin)
    }

    private var statusLine: some View {
        HStack(spacing: CGFloat.ds.spacing.xs) {
            DesignText(
                MeetingDisplayFormat.statusTitle(meeting.status),
                style: TextStyle.ds.headline.semiBold,
                color: statusColor,
                lineLimit: 1
            )
            dot
            DesignText(
                MeetingDisplayFormat.schedule(meeting.startAt),
                style: TextStyle.ds.headline.regular,
                color: Color.ds.text.neutral.secondary,
                lineLimit: 1
            )
            dot
            DesignText(
                MeetingDisplayFormat.joinedSummary(meeting.joinedCount),
                style: TextStyle.ds.headline.regular,
                color: Color.ds.text.neutral.secondary,
                lineLimit: 1
            )
        }
        .frame(height: MeetingDetailSummaryLayout.statusLineHeight)
    }

    private var dot: some View {
        Circle()
            .fill(Color.ds.text.neutral.secondary)
            .frame(width: MeetingDetailSummaryLayout.dotSize, height: MeetingDetailSummaryLayout.dotSize)
    }

    private var statusColor: Color {
        meeting.status == .recruiting ? Color.ds.text.status.positive : Color.ds.text.neutral.subtle
    }

    private var infoRow: some View {
        HStack(spacing: CGFloat.ds.spacing.xs) {
            infoItem(Image.ds.icon.popcorn.outlined, meeting.category.name)
            Spacer(minLength: 0)
            infoItem(Image.ds.icon.idCard.outlined, MeetingDisplayFormat.ageRange(meeting.ageRange))
            Spacer(minLength: 0)
            infoItem(Image.ds.icon.gender.outlined, MeetingDisplayFormat.gender(meeting.genderRestriction))
            Spacer(minLength: 0)
            infoItem(Image.ds.icon.people.outlined, MeetingDisplayFormat.capacity(meeting.capacity))
        }
        .padding(.top, MeetingDetailSummaryLayout.infoTopPadding)
        .padding(.bottom, MeetingDetailSummaryLayout.infoBottomPadding)
        .padding(.horizontal, MeetingDetailSummaryLayout.titleInset)
    }

    /// 칩은 시안 폭 64 를 바닥으로 두고 글자가 길면 넓어진다. 「20대~30대」 는 64 를 넘는다.
    /// 칩이 사이 칸보다 먼저 자리를 받아 글자 폭만큼 넓어지고, 줄이 모자랄 만큼 긴 글자만 말줄임한다.
    private func infoItem(_ icon: Image, _ label: String) -> some View {
        VStack(spacing: MeetingDetailSummaryLayout.infoSpacing) {
            icon
                .resizable()
                .frame(width: CGFloat.ds.iconSize._28, height: CGFloat.ds.iconSize._28)
                .foregroundStyle(Color.ds.text.neutral.primary)
            DesignText(
                label,
                style: TextStyle.ds.caption1.regular,
                color: Color.ds.text.neutral.secondary,
                alignment: .center,
                lineLimit: 1
            )
            .frame(height: MeetingDetailSummaryLayout.infoLabelHeight)
        }
        .frame(minWidth: MeetingDetailSummaryLayout.infoMinWidth)
        .layoutPriority(1)
    }
}

/// 장소 이름과 주소 카드.
private struct MeetingDetailPlaceCard: View {
    let place: Place

    var body: some View {
        HStack(spacing: MeetingDetailSummaryLayout.placeSpacing) {
            ZStack {
                // 시안 지도 그림을 고정으로 쓴다. 장소 좌표 지도는 서버 연결 때 붙인다.
                Image.ds.placeholder.map
                    .resizable()
                    .foregroundStyle(Color.ds.fill.neutral.strong)
                Image.ds.icon.location.filled
                    .resizable()
                    .frame(width: CGFloat.ds.iconSize._24, height: CGFloat.ds.iconSize._24)
                    .foregroundStyle(Color.ds.fill.accent.vivid)
                    .offset(y: MeetingDetailSummaryLayout.mapPinOffsetY)
            }
            .frame(width: MeetingDetailSummaryLayout.mapSide, height: MeetingDetailSummaryLayout.mapSide)
            .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._6))
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                DesignText(place.name, style: TextStyle.ds.headline.semiBold, lineLimit: 1)
                Spacer(minLength: CGFloat.ds.spacing.xs)
                DesignText(
                    place.address,
                    style: TextStyle.ds.caption1.medium,
                    color: Color.ds.text.neutral.subtle,
                    lineLimit: 1
                )
                .frame(height: MeetingDetailSummaryLayout.addressHeight)
            }
            .padding(.vertical, MeetingDetailSummaryLayout.placeTextInset)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: MeetingDetailSummaryLayout.mapSide)
        .padding(MeetingDetailSummaryLayout.placePadding)
        .background(Color.ds.fill.neutral.subtle, in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12))
        .accessibilityElement(children: .combine)
    }
}

private enum MeetingDetailSummaryLayout {
    static let titleSpacing: CGFloat = 6
    static let titleInset: CGFloat = 30
    static let statusLineHeight: CGFloat = 28
    static let dotSize: CGFloat = 2
    static let infoTopPadding: CGFloat = 6
    static let infoBottomPadding: CGFloat = 10
    static let infoSpacing: CGFloat = 6
    static let infoMinWidth: CGFloat = 64
    static let infoLabelHeight: CGFloat = 20
    static let placeSpacing: CGFloat = 10
    static let placePadding: CGFloat = 14
    static let placeTextInset: CGFloat = 2
    static let addressHeight: CGFloat = 16
    static let mapSide: CGFloat = 48
    /// 시안 핀 가운데가 지도 칸 가운데보다 2pt 위다.
    static let mapPinOffsetY: CGFloat = -2
}

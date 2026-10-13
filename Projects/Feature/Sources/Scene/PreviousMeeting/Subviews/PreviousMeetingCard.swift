import Domain
import Foundation
import SharedDesignSystem
import SwiftUI

/// 이전 모임 불러오기의 모임 카드. 고르면 테두리·점선·알림 수가 강조색이 된다.
struct PreviousMeetingCard: View {
    let meeting: Meeting
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: CGFloat.ds.spacing.xs) {
                DesignText(meeting.title, style: TextStyle.ds.headline.semiBold, color: titleColor, lineLimit: 1)
                DesignText("\(meeting.joinedCount)명", style: TextStyle.ds.headline.semiBold, color: joinedColor)
                Spacer(minLength: CGFloat.ds.spacing.xs)
                HStack(spacing: PreviousMeetingCardLayout.bellSpacing) {
                    (isSelected ? Image.ds.icon.bell.filled : Image.ds.icon.bell.outlined)
                        .iconSize(CGFloat.ds.iconSize._18)
                        .foregroundStyle(countColor)
                    DesignText(
                        "\(meeting.notificationRequestCount)명",
                        style: TextStyle.ds.headline.semiBold,
                        color: countColor
                    )
                }
                .padding(.horizontal, PreviousMeetingCardLayout.bellInset)
            }
            .padding(.top, PreviousMeetingCardLayout.topInset)
            .padding(.bottom, PreviousMeetingCardLayout.titleToLine)
            PreviousMeetingDashedLine()
                .stroke(
                    lineColor,
                    style: StrokeStyle(lineWidth: CGFloat.ds.border.thin, dash: PreviousMeetingCardLayout.dash)
                )
                .frame(height: CGFloat.ds.border.thin)
                .padding(.horizontal, -PreviousMeetingCardLayout.lineOutset)
            DesignText(
                PreviousMeetingFormat.dateAndLocation(of: meeting),
                style: PreviousMeetingCardLayout.dateStyle,
                color: titleColor,
                lineLimit: 1
            )
            .frame(height: PreviousMeetingCardLayout.dateHeight)
            .padding(.top, PreviousMeetingCardLayout.lineToDate)
            .padding(.bottom, PreviousMeetingCardLayout.bottomInset)
        }
        .padding(.horizontal, CGFloat.ds.spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: PreviousMeetingCardLayout.cornerRadius)
                .fill(Color.ds.fill.neutral.default)
        )
        .overlay(
            // 시안의 테두리는 바깥쪽이다. 틀 크기는 그대로 두고 테두리만 밖으로 낸다
            RoundedRectangle(cornerRadius: PreviousMeetingCardLayout.cornerRadius + borderWidth / 2)
                .stroke(lineColor, lineWidth: borderWidth)
                .padding(-borderWidth / 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: PreviousMeetingCardLayout.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var titleColor: Color {
        isSelected ? Color.ds.text.neutral.primary : Color.ds.text.neutral.tertiary
    }

    private var joinedColor: Color {
        isSelected ? Color.ds.text.neutral.primary : Color.ds.text.neutral.subtle
    }

    private var countColor: Color {
        isSelected ? Color.ds.text.accent.highlight : Color.ds.text.neutral.tertiary
    }

    private var lineColor: Color {
        isSelected ? Color.ds.text.accent.highlight : Color.ds.border.neutral._40
    }

    private var borderWidth: CGFloat {
        isSelected ? PreviousMeetingCardLayout.selectedBorderWidth : CGFloat.ds.border.thin
    }
}

/// 카드 가운데 점선.
private struct PreviousMeetingDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

private enum PreviousMeetingCardLayout {
    static let dash: [CGFloat] = [4, 4]
    static let cornerRadius: CGFloat = 20
    /// 고른 카드의 바깥 테두리
    static let selectedBorderWidth: CGFloat = 3
    /// 카드 위에서 제목 줄까지
    static let topInset: CGFloat = 20
    /// 제목 줄 아래에서 점선까지
    static let titleToLine: CGFloat = 9
    /// 점선 아래에서 날짜 줄까지
    static let lineToDate: CGFloat = 10
    /// 날짜 줄 높이
    static let dateHeight: CGFloat = 24
    /// 날짜·위치 줄 Regular 14/16 −2%. 시안 `I2774:119964;2774:119850`
    static let dateStyle = TextStyle.ds.pretendard(.regular, size: 14, lineHeight: 16, letterSpacingEm: -0.02)
    /// 날짜 줄 아래에서 카드 아래까지
    static let bottomInset: CGFloat = 20
    /// 점선은 글자 영역보다 양옆으로 2 더 길다
    static let lineOutset: CGFloat = 2
    /// 종 아이콘과 알림 수 사이
    static let bellSpacing: CGFloat = 3
    /// 알림 묶음 양옆 여백
    static let bellInset: CGFloat = 2
}

/// 이전 모임 불러오기의 날짜·위치 표시. 날짜는 한국 시간 기준이다.
enum PreviousMeetingFormat {
    /// 「2026년 7월 22일」
    static func date(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(
                date: .long,
                time: .omitted,
                locale: Locale(identifier: "ko_KR"),
                timeZone: TimeZone(identifier: "Asia/Seoul") ?? .current
            )
        )
    }

    /// 「날짜 : 2026년 7월 22일 / 위치 : 서울특별시 중랑구」
    static func dateAndLocation(of meeting: Meeting) -> String {
        "날짜 : \(date(meeting.startAt)) / 위치 : \(location(of: meeting))"
    }

    /// 「서울특별시 중랑구」. 지역이 없으면 장소 이름이다.
    static func location(of meeting: Meeting) -> String {
        guard let region = meeting.region else { return meeting.place.name }
        return [region.province, region.district].compactMap { $0 }.joined(separator: " ")
    }
}

import SharedDesignSystem
import SwiftUI

/// 왼쪽 라벨, 오른쪽 지금 값 한 줄(시안 Row default). 높이 54, 좌우 16.
/// 끝 아이콘은 값이 있을 때만 보인다(시안 빈 입력에서 숨김).
struct MeetingFormRow: View {
    let label: String
    let value: String?
    let trailingIcon: Image?
    let showsSeparator: Bool

    init(_ label: String, value: String?, trailingIcon: Image? = nil, showsSeparator: Bool = false) {
        self.label = label
        self.value = value
        self.trailingIcon = trailingIcon
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        HStack(spacing: CGFloat.ds.spacing.xs) {
            MeetingFormRowLabel(label)
            Spacer(minLength: CGFloat.ds.spacing.sm)
            if let value {
                // 시안 Trailing: 값과 아이콘(18) 사이 0
                HStack(spacing: 0) {
                    DesignText(
                        value,
                        style: TextStyle.ds.body.regular,
                        color: Color.ds.text.neutral.subtle,
                        lineLimit: 1
                    )
                    if let trailingIcon {
                        trailingIcon
                            .iconSize(CGFloat.ds.iconSize._18)
                            .foregroundStyle(Color.ds.text.neutral.subtle)
                    }
                }
            }
        }
        .padding(.horizontal, CGFloat.ds.spacing.lg)
        .frame(height: MeetingFormPartsLayout.rowHeight)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showsSeparator {
                DesignFormRowSeparator()
            }
        }
    }
}

/// 줄 왼쪽 라벨. 시안 16/400/26 -2% `text/neutral/secondary` 에 가장 가까운 글자 토큰(16/400/24 -1%)이다.
struct MeetingFormRowLabel: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        DesignText(text, style: TextStyle.ds.body.regular, color: Color.ds.text.neutral.secondary)
    }
}

/// 줄 아래 펼친 칸(시안 Row chips·calendar·wheel)의 여백. 위 `top`, 좌우·아래 16.
struct MeetingFormExpandedPadding: ViewModifier {
    let top: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.top, top)
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.bottom, CGFloat.ds.spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func meetingFormExpandedPadding(top: CGFloat) -> some View {
        modifier(MeetingFormExpandedPadding(top: top))
    }
}

/// iOS 기본 메뉴 항목. 지금 고른 항목에만 체크를 붙인다.
struct MeetingFormMenuLabel: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        if isSelected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }
}

enum MeetingFormPartsLayout {
    /// 시안 Row default: 위아래 10 + 내용 34.
    static let rowHeight: CGFloat = 54
    /// 시안 Row text 의 소개 줄: 위아래 10 + 글자 영역 96.
    static let introHeight: CGFloat = 116
    /// 시안 Row long text 의 상세 정보 줄.
    static let detailHeight: CGFloat = 304
    /// 시안 Div 의 칸 사이 간격.
    static let cardSpacing: CGFloat = 28
    /// 시안 Div 의 아래 여백.
    static let bottomInset: CGFloat = 60
}

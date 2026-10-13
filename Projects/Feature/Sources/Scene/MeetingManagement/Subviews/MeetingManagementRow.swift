import SharedDesignSystem
import SwiftUI

/// 사이드바의 한 칸. 목록 줄 부품이 머지되기 전까지 시안 값으로 직접 그린다.
struct MeetingManagementRow: View {
    private let title: String
    private let value: String?
    private let action: () -> Void

    init(_ title: String, value: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                DesignText(
                    title,
                    style: MeetingManagementRowLayout.titleStyle,
                    color: Color.ds.text.neutral.secondary,
                    lineLimit: 1
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: MeetingManagementRowLayout.valueToChevronSpacing) {
                    if let value {
                        DesignText(
                            value,
                            style: MeetingManagementRowLayout.valueStyle,
                            color: Color.ds.text.neutral.subtle,
                            lineLimit: 1
                        )
                    }
                    Image.ds.icon.chevron.right
                        .iconSize(MeetingManagementRowLayout.chevronSize)
                        .foregroundStyle(Color.ds.text.neutral.subtle)
                }
            }
            .modifier(MeetingManagementRowFrame())
        }
        .buttonStyle(.plain)
    }
}

/// 「모임 삭제」 칸. 목록 줄로 바꾸지 않는다.
struct MeetingManagementDeleteRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            DesignText(
                "모임 삭제",
                style: MeetingManagementRowLayout.titleStyle,
                color: Color.ds.text.status.negative,
                lineLimit: 1
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(MeetingManagementRowFrame())
        }
        .buttonStyle(.plain)
    }
}

private struct MeetingManagementRowFrame: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: MeetingManagementRowLayout.contentHeight)
            .padding(.vertical, MeetingManagementRowLayout.verticalPadding)
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .contentShape(Rectangle())
    }
}

private enum MeetingManagementRowLayout {
    // 시안 16/400/26, 자간 -2%. 같은 토큰이 없어 자간이 같은 Headline(16/22) 을 쓴다.
    // 칸 높이는 contentHeight 로 고정이라 줄 높이 차이는 위치에 안 드러난다.
    static let titleStyle: TextStyle = TextStyle.ds.headline.regular
    static let valueStyle: TextStyle = TextStyle.ds.body.regular
    static let valueToChevronSpacing: CGFloat = 0
    static let chevronSize: CGFloat = CGFloat.ds.iconSize._18
    static let contentHeight: CGFloat = 34
    static let verticalPadding: CGFloat = 10
}

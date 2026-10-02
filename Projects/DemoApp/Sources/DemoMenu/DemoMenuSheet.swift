import SharedDesignSystem
import SwiftUI

/// 데모 버튼을 누르면 뜨는 시트. 「목록으로 돌아가기」와, 상태가 있으면 상태 목록을 보인다.
struct DemoMenuSheet: View {
    let options: [DemoMenuOption]
    let selectedID: String?
    let onExit: () -> Void
    let onSelect: (String) -> Void

    @State private var contentHeight: CGFloat = 320

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            exitRow

            if !options.isEmpty {
                DesignText("화면 상태", style: TextStyle.ds.title3.semiBold)
                    .padding(.top, CGFloat.ds.spacing.sm)

                ForEach(options) { option in
                    optionRow(option)
                }
            }
        }
        .padding(.top, CGFloat.ds.spacing.xxl)
        .padding(.horizontal, CGFloat.ds.layout.margin)
        .padding(.bottom, CGFloat.ds.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            contentHeight = height
        }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.ds.fill.neutral.muted)
        .presentationCornerRadius(CGFloat.ds.radius._24)
    }

    private var exitRow: some View {
        Button(action: onExit) {
            HStack(spacing: DemoMenuSheetLayout.iconSpacing) {
                Image(systemName: "chevron.left")
                    .font(TextStyle.ds.caption1.semiBold.font)
                    .foregroundStyle(Color.ds.text.neutral.primary)
                DesignText("목록으로 돌아가기", style: TextStyle.ds.headline.medium)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .frame(height: DemoMenuSheetLayout.rowHeight)
            .background(
                Color.ds.fill.neutral.subtle,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, CGFloat.ds.spacing.sm)
    }

    private func optionRow(_ option: DemoMenuOption) -> some View {
        let isSelected = option.id == selectedID
        return Button {
            onSelect(option.id)
        } label: {
            HStack(spacing: CGFloat.ds.spacing.md) {
                DesignText(option.title, style: TextStyle.ds.headline.medium)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(TextStyle.ds.caption1.bold.font)
                        .foregroundStyle(Color.ds.text.accent.subtle)
                }
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .frame(height: DemoMenuSheetLayout.rowHeight)
            .background(
                isSelected ? Color.ds.fill.neutral.strong : Color.ds.fill.neutral.subtle,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private enum DemoMenuSheetLayout {
    static let rowHeight: CGFloat = 52
    static let iconSpacing: CGFloat = 10
}

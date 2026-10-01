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
                DesignText("화면 상태", style: TextStyle.ds.title.xsmall18Semibold)
                    .padding(.top, CGFloat.ds.spacing.sm)

                ForEach(options) { option in
                    optionRow(option)
                }
            }
        }
        .padding(.top, CGFloat.ds.spacing.xxl)
        .padding(.horizontal, CGFloat.ds.spacing.lg)
        .padding(.bottom, CGFloat.ds.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            contentHeight = height
        }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.ds.background.grayDark)
        .presentationCornerRadius(CGFloat.ds.radius.xxlg)
    }

    private var exitRow: some View {
        Button(action: onExit) {
            HStack(spacing: 10) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.ds.text.neutral.lighter)
                DesignText("목록으로 돌아가기", style: TextStyle.ds.label.large16Medium)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .frame(height: DemoMenuSheetLayout.rowHeight)
            .background(
                Color.ds.background.grayDarker,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
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
                DesignText(option.title, style: TextStyle.ds.label.large16Medium)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.ds.text.primary.basic)
                }
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .frame(height: DemoMenuSheetLayout.rowHeight)
            .background(
                isSelected ? DemoPalette.selectedRow : Color.ds.background.grayDarker,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private enum DemoMenuSheetLayout {
    static let rowHeight: CGFloat = 52
}

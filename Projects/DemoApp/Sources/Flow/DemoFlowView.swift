import SharedDesignSystem
import SwiftUI

/// 흐름 하나의 화면 목록. 줄마다 화면 이름과 상태 개수를 보인다.
struct DemoFlowView: View {
    let flow: DemoFlow
    let onBack: () -> Void
    let onOpen: (DemoScreen) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DemoFlowLayout.sectionSpacing) {
                DemoBackPill(title: "모지 데모", action: onBack)

                VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                    DesignText(flow.title, style: TextStyle.ds.title2.bold)
                    DesignText(
                        flow.screenCountTitle,
                        style: TextStyle.ds.subtext.regular,
                        color: Color.ds.text.neutral.tertiary
                    )
                }

                VStack(spacing: 0) {
                    ForEach(flow.screens) { screen in
                        screenRow(screen)
                    }
                }
                .background(
                    Color.ds.fill.neutral.subtle,
                    in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
                )

                DesignText(
                    "이 흐름에 화면이 생기면 여기에 한 줄씩 추가된다",
                    style: TextStyle.ds.caption2.medium,
                    color: Color.ds.text.neutral.subtle,
                    alignment: .center
                )
                .padding(.horizontal, CGFloat.ds.spacing.lg)
                .padding(.vertical, CGFloat.ds.spacing.md)
                .frame(maxWidth: .infinity, minHeight: DemoFlowLayout.placeholderMinHeight)
                .overlay {
                    RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
                        .strokeBorder(
                            Color.ds.border.neutral._20,
                            style: StrokeStyle(lineWidth: CGFloat.ds.border.thin, dash: DemoFlowLayout.placeholderDash)
                        )
                }
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
            .padding(.top, CGFloat.ds.spacing.sm)
            .padding(.bottom, CGFloat.ds.spacing.xl)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
    }

    private func screenRow(_ screen: DemoScreen) -> some View {
        Button {
            onOpen(screen)
        } label: {
            HStack(spacing: CGFloat.ds.spacing.md) {
                VStack(alignment: .leading, spacing: DemoFlowLayout.rowTextSpacing) {
                    DesignText(screen.title, style: TextStyle.ds.body.semiBold)
                    DesignText(
                        screen.stateSummary,
                        style: TextStyle.ds.caption2.medium,
                        color: Color.ds.text.neutral.tertiary
                    )
                }
                Spacer(minLength: 0)
                DemoChevron()
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.vertical, CGFloat.ds.spacing.md)
            .frame(minHeight: DemoFlowLayout.rowMinHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private enum DemoFlowLayout {
    static let sectionSpacing: CGFloat = 20
    static let placeholderMinHeight: CGFloat = 52
    static let placeholderDash: [CGFloat] = [4, 4]
    static let rowTextSpacing: CGFloat = 2
    static let rowMinHeight: CGFloat = 64
}

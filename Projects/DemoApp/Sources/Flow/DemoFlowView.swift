import SharedDesignSystem
import SwiftUI

/// 흐름 하나의 화면 목록. 줄마다 화면 이름과 상태 개수를 보인다.
struct DemoFlowView: View {
    let flow: DemoFlow
    let onBack: () -> Void
    let onOpen: (DemoScreen) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DemoBackPill(title: "모지 데모", action: onBack)

                VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                    DesignText(flow.title, style: TextStyle.ds.title.large24Bold)
                    DesignText(
                        flow.screenCountTitle,
                        style: TextStyle.ds.body.small14Regular,
                        color: Color.ds.text.neutral.light
                    )
                }

                VStack(spacing: 0) {
                    ForEach(flow.screens) { screen in
                        screenRow(screen)
                    }
                }
                .background(
                    Color.ds.background.grayDarker,
                    in: RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
                )

                DesignText(
                    "이 흐름에 화면이 생기면 여기에 한 줄씩 추가된다",
                    style: TextStyle.ds.label.small12Medium,
                    color: Color.ds.text.neutral.basic,
                    alignment: .center
                )
                .padding(.horizontal, CGFloat.ds.spacing.lg)
                .padding(.vertical, CGFloat.ds.spacing.md)
                .frame(maxWidth: .infinity, minHeight: 52)
                .overlay {
                    RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
                        .strokeBorder(
                            Color.ds.border.neutral.darker,
                            style: StrokeStyle(lineWidth: CGFloat.ds.border.thin, dash: [4, 4])
                        )
                }
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.top, CGFloat.ds.spacing.sm)
            .padding(.bottom, CGFloat.ds.spacing.xl)
        }
        .background(Color.ds.background.black.ignoresSafeArea())
    }

    private func screenRow(_ screen: DemoScreen) -> some View {
        Button {
            onOpen(screen)
        } label: {
            HStack(spacing: CGFloat.ds.spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    DesignText(screen.title, style: TextStyle.ds.body.medium16Semibold)
                    DesignText(screen.stateSummary, style: TextStyle.ds.label.small12Medium, color: DemoPalette.caption)
                }
                Spacer(minLength: 0)
                DemoChevron()
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.vertical, CGFloat.ds.spacing.md)
            .frame(minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

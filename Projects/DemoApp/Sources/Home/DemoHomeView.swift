import SharedDesignSystem
import SwiftUI

/// 첫 화면. 위에서부터 바뀐 것, 흐름 일곱, 디자인 시스템, 바닥 글.
struct DemoHomeView: View {
    let buildInfo: DemoBuildInfo
    let onOpen: (DemoRoute) -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                    header
                    DemoSection(title: "이번 빌드에서 바뀐 것") {
                        changeCard
                    }
                    DemoSection(title: "흐름") {
                        flowList
                    }
                    DemoSection(title: "디자인 시스템") {
                        galleryRow
                    }
                    Spacer(minLength: 0)
                    footer
                }
                .padding(.horizontal, CGFloat.ds.spacing.lg)
                .padding(.top, CGFloat.ds.spacing.md)
                .padding(.bottom, CGFloat.ds.spacing.xl)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
        .background(Color.ds.background.black.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            DesignText("모지 데모", style: TextStyle.ds.heading.medium28Bold)
            DesignText(
                "화면을 눌러 서버 없이 확인합니다",
                style: TextStyle.ds.body.small14Regular,
                color: Color.ds.text.neutral.light
            )
        }
    }

    // 누를 수 없는 글 한 줄. 업로드 문구(해시 포함)이거나 「개발 빌드」다.
    private var changeCard: some View {
        DesignText(buildInfo.changeSummary, style: TextStyle.ds.body.medium16Semibold)
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.vertical, CGFloat.ds.spacing.md)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(
                Color.ds.background.grayDarker,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
                    .strokeBorder(DemoPalette.changeBorder, lineWidth: CGFloat.ds.border.thin)
            }
    }

    private var flowList: some View {
        VStack(spacing: 0) {
            ForEach(Array(DemoFlow.allCases.enumerated()), id: \.element) { index, flow in
                if index > 0 {
                    Rectangle()
                        .fill(Color.ds.border.neutral.darker)
                        .frame(height: CGFloat.ds.border.thin)
                }
                flowRow(flow)
            }
        }
        .background(
            Color.ds.background.grayDarker,
            in: RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
        )
        .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous))
    }

    @ViewBuilder
    private func flowRow(_ flow: DemoFlow) -> some View {
        if flow.isReady {
            Button {
                onOpen(.flow(flow))
            } label: {
                DemoRow {
                    DesignText(flow.title, style: TextStyle.ds.body.medium16Semibold)
                } trailing: {
                    HStack(spacing: 10) {
                        DesignText(
                            flow.screenCountLabel,
                            style: TextStyle.ds.label.small12Medium,
                            color: DemoPalette.caption
                        )
                        DemoChevron()
                    }
                }
            }
            .buttonStyle(.plain)
        } else {
            DemoRow {
                DesignText(flow.title, style: TextStyle.ds.body.medium16Regular, color: Color.ds.text.neutral.basic)
            } trailing: {
                DesignText("준비 중", style: TextStyle.ds.label.small12Medium, color: Color.ds.text.neutral.basic)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var galleryRow: some View {
        Button {
            onOpen(.gallery)
        } label: {
            DemoRow {
                DesignText("색 · 글꼴 · 버튼", style: TextStyle.ds.body.medium16Semibold)
            } trailing: {
                DemoChevron()
            }
            .background(
                Color.ds.background.grayDarker,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var footer: some View {
        if let footer = buildInfo.footer {
            DesignText(
                footer,
                style: TextStyle.ds.label.small12Medium,
                color: Color.ds.text.neutral.basic,
                alignment: .center
            )
            .frame(maxWidth: .infinity)
        }
    }
}

/// 칸 제목과 그 아래 내용.
private struct DemoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            DesignText(title, style: TextStyle.ds.label.small12Medium, color: DemoPalette.caption)
                .padding(.leading, CGFloat.ds.spacing.xs)
            content
        }
    }
}

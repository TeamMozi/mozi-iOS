import MoziDemoKit
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
                        galleryList
                    }
                    Spacer(minLength: 0)
                    footer
                }
                .padding(.horizontal, CGFloat.ds.layout.margin)
                .padding(.top, CGFloat.ds.spacing.md)
                .padding(.bottom, CGFloat.ds.spacing.xl)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DemoHomeLayout.headerSpacing) {
            DesignText("모지 데모", style: TextStyle.ds.title1.bold)
            DesignText(
                "화면을 눌러 서버 없이 확인합니다",
                style: TextStyle.ds.subtext.regular,
                color: Color.ds.text.neutral.tertiary
            )
        }
    }

    // 누를 수 없는 글 한 줄. 업로드 문구(해시 포함)이거나 「개발 빌드」다.
    private var changeCard: some View {
        DesignText(buildInfo.changeSummary, style: TextStyle.ds.body.semiBold)
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.vertical, CGFloat.ds.spacing.md)
            .frame(maxWidth: .infinity, minHeight: DemoHomeLayout.changeCardMinHeight, alignment: .leading)
            .background(
                Color.ds.fill.neutral.subtle,
                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
                    .strokeBorder(Color.ds.border.neutral._20, lineWidth: CGFloat.ds.border.thin)
            }
    }

    private var flowList: some View {
        VStack(spacing: 0) {
            ForEach(Array(DemoFlow.allCases.enumerated()), id: \.element) { index, flow in
                if index > 0 {
                    Rectangle()
                        .fill(Color.ds.border.neutral._20)
                        .frame(height: CGFloat.ds.border.thin)
                }
                flowRow(flow)
            }
        }
        .background(
            Color.ds.fill.neutral.subtle,
            in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
        )
        .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous))
    }

    @ViewBuilder
    private func flowRow(_ flow: DemoFlow) -> some View {
        if flow.isReady {
            Button {
                onOpen(.flow(flow))
            } label: {
                DemoRow {
                    DesignText(flow.title, style: TextStyle.ds.body.semiBold)
                } trailing: {
                    HStack(spacing: DemoHomeLayout.trailingSpacing) {
                        DesignText(
                            flow.screenCountLabel,
                            style: TextStyle.ds.caption2.medium,
                            color: Color.ds.text.neutral.tertiary
                        )
                        DemoChevron()
                    }
                }
            }
            .buttonStyle(.plain)
        } else {
            DemoRow {
                DesignText(flow.title, style: TextStyle.ds.body.regular, color: Color.ds.text.neutral.subtle)
            } trailing: {
                DesignText("준비 중", style: TextStyle.ds.caption2.medium, color: Color.ds.text.neutral.subtle)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var galleryList: some View {
        VStack(spacing: 0) {
            ForEach(Array(GalleryScreen.allCases.enumerated()), id: \.element) { index, screen in
                if index > 0 {
                    Rectangle()
                        .fill(Color.ds.border.neutral._20)
                        .frame(height: CGFloat.ds.border.thin)
                }
                Button {
                    onOpen(.gallery(screen))
                } label: {
                    DemoRow {
                        DesignText(screen.title, style: TextStyle.ds.body.semiBold)
                    } trailing: {
                        DemoChevron()
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            Color.ds.fill.neutral.subtle,
            in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
        )
        .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous))
    }

    @ViewBuilder
    private var footer: some View {
        if let footer = buildInfo.footer {
            DesignText(
                footer,
                style: TextStyle.ds.caption2.medium,
                color: Color.ds.text.neutral.subtle,
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
            DesignText(title, style: TextStyle.ds.caption2.medium, color: Color.ds.text.neutral.tertiary)
                .padding(.leading, CGFloat.ds.spacing.xs)
            content
        }
    }
}

private enum DemoHomeLayout {
    static let headerSpacing: CGFloat = 6
    static let changeCardMinHeight: CGFloat = 64
    static let trailingSpacing: CGFloat = 10
}

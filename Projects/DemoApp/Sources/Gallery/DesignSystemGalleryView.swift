import SharedDesignSystem
import SwiftUI

/// 디자인 시스템 모음. 색·글자·버튼·소셜을 한 장에 쌓은 스크롤 화면이다.
struct DesignSystemGalleryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                DesignText("디자인 시스템 모음", style: TextStyle.ds.title.large24Bold)
                colorsSection
                typographySection
                buttonsSection
                socialSection
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.top, CGFloat.ds.spacing.lg)
            .padding(.bottom, CGFloat.ds.spacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.ds.background.black.ignoresSafeArea())
    }

    private var colorsSection: some View {
        GallerySection(title: "Colors", spacing: CGFloat.ds.spacing.md) {
            SwatchGroup(title: "Text", swatches: GallerySwatch.text)
            SwatchGroup(title: "Background", swatches: GallerySwatch.background)
            SwatchGroup(title: "Button Primary BG", swatches: GallerySwatch.buttonPrimaryBackground)
        }
    }

    private var typographySection: some View {
        GallerySection(title: "Typography", spacing: 10) {
            ForEach(GalleryTypeSample.all) { sample in
                HStack(alignment: .firstTextBaseline, spacing: CGFloat.ds.spacing.md) {
                    DesignText(sample.text, style: sample.style, lineLimit: 1)
                    Spacer(minLength: 0)
                    DesignText(sample.name, style: TextStyle.ds.label.small12Medium, color: DemoPalette.caption)
                }
            }
        }
    }

    private var buttonsSection: some View {
        GallerySection(title: "Buttons", spacing: 10) {
            DesignButton("Primary", variant: .primary, size: .lg, isFullWidth: true) {}
            DesignButton("Secondary", variant: .secondary, size: .lg, isFullWidth: true) {}
            DesignButton("Outlined", variant: .outlined, size: .lg, isFullWidth: true) {}
            DesignButton("Disabled Primary", variant: .primary, size: .lg, isEnabled: false, isFullWidth: true) {}
        }
    }

    private var socialSection: some View {
        GallerySection(title: "Social", spacing: 10) {
            SocialLoginButton(provider: .kakao) {}
            SocialLoginButton(provider: .apple) {}
        }
    }
}

private struct GallerySection<Content: View>: View {
    let title: String
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            DesignText(title, style: TextStyle.ds.title.xsmall18Semibold)
            content
        }
    }
}

private struct SwatchGroup: View {
    let title: String
    let swatches: [GallerySwatch]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: CGFloat.ds.spacing.sm, alignment: .top),
        count: 5
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            DesignText(title, style: TextStyle.ds.label.small12Medium, color: DemoPalette.caption)
            LazyVGrid(columns: columns, alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
                ForEach(swatches) { swatch in
                    VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                        RoundedRectangle(cornerRadius: CGFloat.ds.radius.sm, style: .continuous)
                            .fill(swatch.color)
                            .frame(height: 44)
                            .overlay {
                                if swatch.hasBorder {
                                    RoundedRectangle(cornerRadius: CGFloat.ds.radius.sm, style: .continuous)
                                        .strokeBorder(Color.ds.border.neutral.darker, lineWidth: CGFloat.ds.border.thin)
                                }
                            }
                        DesignText(
                            swatch.caption,
                            style: TextStyle.ds.label.small12Medium,
                            color: Color.ds.text.neutral.light,
                            lineLimit: 1
                        )
                    }
                }
            }
        }
    }
}

/// 색 견본 한 칸. 글은 토큰의 hex 나 상태 이름이다.
private struct GallerySwatch: Identifiable {
    let caption: String
    let color: Color
    var hasBorder = false

    var id: String { caption }

    static let text = [
        GallerySwatch(caption: "E9DE6F", color: Color.ds.text.primary.basic),
        GallerySwatch(caption: "BAB259", color: Color.ds.text.primary.dark),
        GallerySwatch(caption: "8C8543", color: Color.ds.text.primary.darker),
        GallerySwatch(caption: "D0E77C", color: Color.ds.text.secondary.basic),
        GallerySwatch(caption: "FFFFFF", color: Color.ds.text.neutral.white),
    ]

    static let background = [
        GallerySwatch(caption: "000000", color: Color.ds.background.black, hasBorder: true),
        GallerySwatch(caption: "1A1A1A", color: Color.ds.background.grayDarker, hasBorder: true),
        GallerySwatch(caption: "333333", color: Color.ds.background.grayDark),
    ]

    static let buttonPrimaryBackground = [
        GallerySwatch(caption: "기본", color: Color.ds.button.primary.background.default),
        GallerySwatch(caption: "눌림", color: Color.ds.button.primary.background.pressed),
        GallerySwatch(caption: "비활성", color: Color.ds.button.primary.background.disabled),
    ]
}

/// 글자 견본 한 줄.
private struct GalleryTypeSample: Identifiable {
    let name: String
    let text: String
    let style: TextStyle

    var id: String { name }

    static let all = [
        GalleryTypeSample(name: "Heading 32 Bold", text: "모든 모임", style: TextStyle.ds.heading.large32Bold),
        GalleryTypeSample(name: "Title 24 Bold", text: "모든 모임", style: TextStyle.ds.title.large24Bold),
        GalleryTypeSample(name: "Title 18 Semibold", text: "모든 모임", style: TextStyle.ds.title.xsmall18Semibold),
        GalleryTypeSample(name: "Body 16 Regular", text: "동네라서 가능한 모든 것", style: TextStyle.ds.body.medium16Regular),
        GalleryTypeSample(name: "Body 14 Regular", text: "동네라서 가능한 모든 것", style: TextStyle.ds.body.small14Regular),
        GalleryTypeSample(name: "Label 14 Medium", text: "동네라서 가능한 모든 것", style: TextStyle.ds.label.medium14Medium),
        GalleryTypeSample(name: "Button 18 Semibold", text: "시작하기", style: TextStyle.ds.button.lg18Semibold),
    ]
}

#Preview("Design System Gallery") {
    DesignSystemGalleryView()
        .onAppear {
            _ = DesignSystemFontRegistration.registerIfNeeded()
        }
}

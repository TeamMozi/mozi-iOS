#if DEBUG
import SwiftUI

/// DEBUG-only visual catalog for SharedDesignSystem tokens/components.
struct DesignSystemGallery: View {
    @State private var selectedSection: GallerySection? = .colors

    var body: some View {
        NavigationSplitView {
            List(GallerySection.allCases, selection: $selectedSection) { section in
                Text(section.title)
                    .foregroundStyle(Color.ds.text.neutral.white)
                    .tag(section)
            }
            .navigationTitle("Design System")
            .scrollContentBackground(.hidden)
            .background(Color.ds.background.black)
        } detail: {
            Group {
                if let selectedSection {
                    sectionDetail(selectedSection)
                } else {
                    ContentUnavailableView(
                        "Select a section",
                        systemImage: "sidebar.left",
                        description: Text("Choose a design system section from the list.")
                    )
                    .foregroundStyle(Color.ds.text.neutral.basic)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.ds.background.black)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func sectionDetail(_ section: GallerySection) -> some View {
        switch section {
        case .colors:
            GalleryColorsSection()
        case .typography:
            GalleryTypographySection()
        case .buttons:
            GalleryButtonsSection()
        case .social:
            GallerySocialSection()
        }
    }
}

// MARK: - Section Model

private enum GallerySection: String, CaseIterable, Identifiable, Hashable {
    case colors
    case typography
    case buttons
    case social

    var id: String { rawValue }

    var title: String {
        switch self {
        case .colors: "Colors"
        case .typography: "Typography"
        case .buttons: "Buttons"
        case .social: "Social"
        }
    }
}

// MARK: - Section Screens

private struct GalleryColorsSection: View {
    var body: some View {
        GallerySectionScaffold(
            title: "Colors",
            subtitle: "Semantic color tokens used by Feature"
        ) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.md) {
                colorRow(
                    title: "Text",
                    swatches: [
                        ("white", Color.ds.text.neutral.white),
                        ("basic", Color.ds.text.neutral.basic),
                        ("dark", Color.ds.text.neutral.dark),
                        ("primary", Color.ds.text.primary.basic),
                        ("secondary", Color.ds.text.secondary.basic),
                    ]
                )

                colorRow(
                    title: "Background",
                    swatches: [
                        ("black", Color.ds.background.black),
                        ("grayDarker", Color.ds.background.grayDarker),
                        ("grayDark", Color.ds.background.grayDark),
                    ]
                )

                colorRow(
                    title: "Button Primary BG",
                    swatches: [
                        ("default", Color.ds.button.primary.background.default),
                        ("pressed", Color.ds.button.primary.background.pressed),
                        ("disabled", Color.ds.button.primary.background.disabled),
                    ]
                )

                colorRow(
                    title: "Social Colors",
                    swatches: [
                        ("kakao", Color.ds.social.kakao),
                        ("appleBG", Color.ds.social.appleBackground),
                        ("appleBorder", Color.ds.social.appleBorder),
                    ]
                )
            }
        }
    }

    private func colorRow(title: String, swatches: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
            DesignText(title, style: TextStyle.ds.label.medium14Medium, color: Color.ds.text.neutral.basic)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CGFloat.ds.spacing.sm) {
                    ForEach(Array(swatches.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: CGFloat.ds.spacing.xs) {
                            RoundedRectangle(cornerRadius: CGFloat.ds.radius.xsm, style: .continuous)
                                .fill(item.1)
                                .frame(width: 56, height: 56)
                                .overlay {
                                    RoundedRectangle(cornerRadius: CGFloat.ds.radius.xsm, style: .continuous)
                                        .strokeBorder(
                                            Color.ds.border.neutral.basic.opacity(0.4),
                                            lineWidth: CGFloat.ds.border.thin
                                        )
                                }

                            DesignText(
                                item.0,
                                style: TextStyle.ds.label.small12Medium,
                                color: Color.ds.text.neutral.light,
                                alignment: .center
                            )
                            .frame(width: 64)
                        }
                    }
                }
            }
        }
    }
}

private struct GalleryTypographySection: View {
    var body: some View {
        GallerySectionScaffold(
            title: "Typography",
            subtitle: "Pretendard text styles from TextStyle.ds"
        ) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
                DesignText("Heading / large32Bold", style: TextStyle.ds.heading.large32Bold)
                DesignText("Title / large24Bold", style: TextStyle.ds.title.large24Bold)
                DesignText("Title / medium22Semibold", style: TextStyle.ds.title.medium22Semibold)
                DesignText(
                    "Body / medium16Regular",
                    style: TextStyle.ds.body.medium16Regular,
                    color: Color.ds.text.neutral.basic
                )
                DesignText(
                    "Body / small14Regular",
                    style: TextStyle.ds.body.small14Regular,
                    color: Color.ds.text.neutral.basic
                )
                DesignText(
                    "Label / medium14Medium",
                    style: TextStyle.ds.label.medium14Medium,
                    color: Color.ds.text.primary.basic
                )
                DesignText("Button / lg18Semibold", style: TextStyle.ds.button.lg18Semibold)
            }
        }
    }
}

private struct GalleryButtonsSection: View {
    var body: some View {
        GallerySectionScaffold(
            title: "DesignButton",
            subtitle: "Variants, sizes, full-width, disabled, icons"
        ) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.md) {
                buttonVariantRow(title: "Primary", variant: .primary)
                buttonVariantRow(title: "Secondary", variant: .secondary)
                buttonVariantRow(title: "Outlined", variant: .outlined)
                buttonVariantRow(title: "Text", variant: .text)

                DesignText(
                    "Full width / disabled",
                    style: TextStyle.ds.label.small12Medium,
                    color: Color.ds.text.neutral.basic
                )

                DesignButton("Full Width Primary", variant: .primary, size: .lg, isFullWidth: true) {}
                DesignButton(
                    "Disabled Primary",
                    variant: .primary,
                    size: .md,
                    isEnabled: false,
                    isFullWidth: true
                ) {}
                DesignButton(
                    "With Icons",
                    variant: .secondary,
                    size: .md,
                    leadingIcon: Image(systemName: "checkmark.circle.fill"),
                    trailingIcon: Image(systemName: "chevron.right")
                ) {}
            }
        }
    }

    private func buttonVariantRow(title: String, variant: DesignButtonVariant) -> some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            DesignText(title, style: TextStyle.ds.label.medium14Medium, color: Color.ds.text.neutral.basic)

            HStack(spacing: CGFloat.ds.spacing.sm) {
                DesignButton("sm", variant: variant, size: .sm) {}
                DesignButton("md", variant: variant, size: .md) {}
                DesignButton("lg", variant: variant, size: .lg) {}
            }
        }
    }
}

private struct GallerySocialSection: View {
    var body: some View {
        GallerySectionScaffold(
            title: "SocialLoginButton",
            subtitle: "Kakao / Apple fixed brand buttons"
        ) {
            VStack(spacing: CGFloat.ds.spacing.sm) {
                SocialLoginButton(provider: .kakao) {}
                SocialLoginButton(provider: .apple) {}
            }
        }
    }
}

// MARK: - Shared Scaffold

private struct GallerySectionScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.lg) {
                VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                    DesignText(title, style: TextStyle.ds.title.large24Bold)
                    DesignText(
                        subtitle,
                        style: TextStyle.ds.body.medium16Regular,
                        color: Color.ds.text.neutral.basic
                    )
                }

                content
                    .padding(CGFloat.ds.spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.ds.background.grayDarker)
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous))
            }
            .padding(CGFloat.ds.spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.ds.background.black)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Design System Gallery") {
    DesignSystemGalleryPreviewHost()
}

/// Preview-only host that registers fonts without making Gallery itself do bootstrap work.
private struct DesignSystemGalleryPreviewHost: View {
    var body: some View {
        DesignSystemGallery()
            .onAppear {
                _ = DesignSystemFontRegistration.registerIfNeeded()
            }
    }
}
#endif

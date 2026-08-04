import SwiftUI

public struct SocialLoginButton: View {
    private let provider: SocialLoginProvider
    private let action: () -> Void

    public init(
        provider: SocialLoginProvider,
        action: @escaping () -> Void
    ) {
        self.provider = provider
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            labelContent
        }
        .buttonStyle(
            SocialLoginButtonChromeStyle(
                background: provider.background,
                content: provider.content,
                border: provider.border
            )
        )
    }

    private var labelContent: some View {
        let textStyle = TextStyle.ds.button.lg18Semibold

        return HStack(spacing: provider.contentGap) {
            providerIcon
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(
                    width: provider.iconSize.width,
                    height: provider.iconSize.height
                )

            Text(provider.title)
                .font(textStyle.font)
                .kerning(textStyle.letterSpacing)
                .lineSpacing(textStyle.additionalLineSpacing)
                .lineLimit(1)
        }
    }

    private var providerIcon: Image {
        switch provider {
        case .kakao:
            SharedDesignSystemAsset.iconSocialKakao.swiftUIImage
        case .apple:
            SharedDesignSystemAsset.iconSocialApple.swiftUIImage
        }
    }
}

private struct SocialLoginButtonChromeStyle: ButtonStyle {
    let background: TokenColor
    let content: TokenColor
    let border: TokenColor?

    func makeBody(configuration: Configuration) -> some View {
        // Full-width social CTAs expand first, then paint chrome.
        configuration.label
            .foregroundStyle(content.color)
            .frame(
                maxWidth: .infinity,
                minHeight: SocialLoginButtonMetrics.height,
                maxHeight: SocialLoginButtonMetrics.height
            )
            .background(background.color)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: SocialLoginButtonMetrics.cornerRadius,
                    style: .continuous
                )
            )
            .overlay {
                if let border {
                    RoundedRectangle(
                        cornerRadius: SocialLoginButtonMetrics.cornerRadius,
                        style: .continuous
                    )
                    .strokeBorder(
                        border.color,
                        lineWidth: SocialLoginButtonMetrics.borderWidth
                    )
                }
            }
            .contentShape(
                RoundedRectangle(
                    cornerRadius: SocialLoginButtonMetrics.cornerRadius,
                    style: .continuous
                )
            )
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

private enum SocialLoginButtonMetrics {
    static let height: CGFloat = SemanticNumber.ControlHeight.lg
    static let cornerRadius: CGFloat = SemanticNumber.Radius.sm
    static let borderWidth: CGFloat = SemanticNumber.Border.thin
}

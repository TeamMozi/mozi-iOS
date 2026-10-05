import SwiftUI

/// 소셜 로그인 버튼. 로고·문구·색이 브랜드 규정으로 고정이라 화면 조각으로 둔다.
/// 너비를 채운다. 비활성은 `.disabled()` 로 걸고 모양은 그대로다. 눌리면 불투명도 0.88 이다.
public struct SocialLoginButton: View {
    private let provider: SocialLoginProvider
    private let action: @MainActor () -> Void

    public init(_ provider: SocialLoginProvider, action: @escaping @MainActor () -> Void) {
        self.provider = provider
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: SocialLoginButtonMetrics.iconSpacing) {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: provider.iconSize.width, height: provider.iconSize.height)

                Text(provider.title)
                    .designButtonText(SocialLoginButtonMetrics.textStyle)
            }
        }
        .buttonStyle(SocialLoginButtonStyle(provider: provider))
    }

    private var icon: Image {
        switch provider {
        case .kakao:
            Image.ds.social.kakao
        case .apple:
            Image.ds.social.apple
        }
    }
}

/// 소셜 로그인 버튼 치수와 글자. Figma login 값이다.
enum SocialLoginButtonMetrics {
    static let height = CGFloat.ds.buttonHeight.controlLg
    static let cornerRadius = CGFloat.ds.radius._8
    static let iconSpacing = CGFloat.ds.spacing.sm
    /// Pretendard SemiBold 18 / 줄 높이 18 / 자간 0. 맞는 글자 스타일이 없어 여기 둔다.
    static let textStyle = TextStyle(
        fontName: DesignSystemFontName.semiBold,
        size: 18,
        lineHeight: 18,
        letterSpacingEm: 0
    )
}

private struct SocialLoginButtonStyle: ButtonStyle {
    let provider: SocialLoginProvider

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: SocialLoginButtonMetrics.cornerRadius, style: .continuous)

        // 먼저 너비를 채우고 높이를 고정한 뒤 바탕을 칠한다.
        configuration.label
            .foregroundStyle(provider.content.color)
            .frame(maxWidth: .infinity)
            .frame(height: SocialLoginButtonMetrics.height)
            .background(provider.background.color, in: shape)
            .contentShape(shape)
            .opacity(DesignButtonPressedOpacity.value(isPressed: configuration.isPressed))
    }
}

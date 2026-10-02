import SharedDesignSystem
import SwiftUI

/// 버튼 화면. 공통 버튼 네 모양과 소셜 로그인 버튼 둘.
struct ButtonGalleryView: View {
    var body: some View {
        GalleryPage(.button) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xxl) {
                GallerySection("Buttons") {
                    DesignButton("Primary", variant: .primary, size: .lg, isFullWidth: true) {}
                    DesignButton("Secondary", variant: .secondary, size: .lg, isFullWidth: true) {}
                    DesignButton("Outlined", variant: .outlined, size: .lg, isFullWidth: true) {}
                    DesignButton(
                        "Disabled Primary",
                        variant: .primary,
                        size: .lg,
                        isEnabled: false,
                        isFullWidth: true
                    ) {}
                }
                GallerySection("Social") {
                    SocialLoginButton(provider: .kakao) {}
                    SocialLoginButton(provider: .apple) {}
                }
            }
        }
    }
}

#Preview("버튼") {
    ButtonGalleryView()
}

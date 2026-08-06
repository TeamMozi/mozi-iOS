import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct LoginView: View {
    @Bindable public var store: StoreOf<LoginFeature>

    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 상단 safe area 하단 ~ 로고 상단
                Spacer()
                    .frame(height: LoginLayout.logoTopInset)

                // 히어로: 로고 + 숏폼(+타이틀 오버레이)
                VStack(spacing: LoginLayout.logoToMarqueeSpacing) {
                    SharedDesignSystemAsset.logoMozi.swiftUIImage
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(
                            width: LoginLayout.logoSize.width,
                            height: LoginLayout.logoSize.height
                        )
                        .accessibilityLabel("Mozi")

                    ZStack {
                        LoginShortformMarqueeView()

                        VStack(spacing: LoginLayout.titleToSubtitleSpacing) {
                            DesignText(
                                "내가 찾던 모든 모임",
                                style: TextStyle.ds.heading.large32Bold,
                                color: Color.ds.text.primary.basic,
                                alignment: .center
                            )

                            VStack(spacing: LoginLayout.subtitleToDescriptionSpacing) {
                                DesignText(
                                    "동네라서 가능한 모든 것",
                                    style: TextStyle.ds.label.large16Medium,
                                    color: Color.ds.text.primary.basic,
                                    alignment: .center
                                )

                                DesignText(
                                    "부담없이 만나는 원데이 모임부터",
                                    style: TextStyle.ds.label.large16Medium,
                                    color: Color.ds.text.primary.basic,
                                    alignment: .center
                                )
                            }
                        }
                        // 로고 하단 기준 타이틀 52 = 숏폼 상단 29 + 카드 내부 top 23
                        .padding(.top, LoginLayout.logoToTitleSpacing - LoginLayout.logoToMarqueeSpacing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.horizontal, LoginLayout.horizontalPadding)
                    }
                    .frame(height: LoginLayout.marqueeHeight)
                }

                // 숏폼 하단 ~ 카카오 버튼 상단
                Spacer()
                    .frame(height: LoginLayout.marqueeToButtonsSpacing)

                VStack(spacing: LoginLayout.buttonSpacing) {
                    SocialLoginButton(provider: .kakao) {
                        store.send(.kakaoLoginTapped)
                    }
                    .disabled(store.isLoading)

                    SocialLoginButton(provider: .apple) {
                        store.send(.appleLoginTapped)
                    }
                    .disabled(store.isLoading)
                }
                .padding(.horizontal, LoginLayout.horizontalPadding)

                Spacer(minLength: 0)
            }

            if store.isLoading {
                ProgressView()
                    .tint(Color.ds.text.neutral.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.background.grayDarker.ignoresSafeArea())
        .task {
            store.send(.onAppear)
        }
    }
}

private enum LoginLayout {
    static let horizontalPadding: CGFloat = 16
    static let buttonSpacing: CGFloat = 8
    /// 상단 safe area 하단 ~ 로고 상단
    static let logoTopInset: CGFloat = 162
    /// 숏폼 하단 ~ 카카오 버튼 상단
    static let marqueeToButtonsSpacing: CGFloat = 64

    static let logoSize = CGSize(width: 150, height: 84)
    /// 로고 하단 ~ 숏폼 상단
    static let logoToMarqueeSpacing: CGFloat = 29
    /// 로고 하단 ~ 타이틀 상단
    static let logoToTitleSpacing: CGFloat = 52
    static let marqueeHeight: CGFloat = 172

    static let titleToSubtitleSpacing: CGFloat = 8
    static let subtitleToDescriptionSpacing: CGFloat = 2
}

// MARK: - Preview

#Preview("Login / Idle") {
    LoginView(
        store: Store(initialState: LoginFeature.State()) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ in
                AuthSession(
                    accessToken: "preview-access",
                    refreshToken: "preview-refresh",
                    isNewUser: false,
                    profileCompleted: true
                )
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

#Preview("Login / Loading") {
    LoginView(
        store: Store(
            initialState: LoginFeature.State(
                isLoading: true
            )
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ in
                try await Task.sleep(nanoseconds: 60_000_000_000)
                return AuthSession(
                    accessToken: "preview-access",
                    refreshToken: "preview-refresh",
                    isNewUser: false,
                    profileCompleted: true
                )
            }
        }
    )
    .onAppear {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }
}

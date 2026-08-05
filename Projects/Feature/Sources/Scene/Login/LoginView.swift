import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct LoginView: View {
    @Bindable public var store: StoreOf<LoginFeature>

    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: CGFloat.ds.spacing.sm) {
                DesignText(
                    "Mozi",
                    style: TextStyle.ds.heading.large32Bold,
                    color: Color.ds.text.neutral.white,
                    alignment: .center
                )

                DesignText(
                    "로그인하고 모지를 시작해요",
                    style: TextStyle.ds.body.medium16Regular,
                    color: Color.ds.text.neutral.basic,
                    alignment: .center
                )
            }

            Spacer()

            VStack(spacing: CGFloat.ds.spacing.sm) {
                if let errorMessage = store.errorMessage {
                    DesignText(
                        errorMessage,
                        style: TextStyle.ds.body.small14Regular,
                        color: Color.ds.text.primary.basic,
                        alignment: .center
                    )
                    .padding(.bottom, CGFloat.ds.spacing.xs)
                }

                SocialLoginButton(provider: .kakao) {
                    store.send(.kakaoLoginTapped)
                }
                .disabled(store.isLoading)

                SocialLoginButton(provider: .apple) {
                    store.send(.appleLoginTapped)
                }
                .disabled(store.isLoading)

                if store.isLoading {
                    ProgressView()
                        .tint(Color.ds.text.neutral.white)
                        .padding(.top, CGFloat.ds.spacing.xs)
                }
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .padding(.bottom, CGFloat.ds.spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.background.black.ignoresSafeArea())
        .task {
            store.send(.onAppear)
        }
    }
}

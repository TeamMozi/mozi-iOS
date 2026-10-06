import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct OnboardingPlaceholderView: View {
    @Bindable public var store: StoreOf<OnboardingPlaceholderFeature>

    public init(store: StoreOf<OnboardingPlaceholderFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: CGFloat.ds.spacing.md) {
            Spacer()

            DesignText(
                "추가 정보 입력이 필요해요",
                style: TextStyle.ds.title2.bold,
                color: Color.ds.text.neutral.primary,
                alignment: .center
            )

            DesignText(
                "온보딩 화면은 곧 연결될 예정이에요.",
                style: TextStyle.ds.body.regular,
                color: Color.ds.text.neutral.subtle,
                alignment: .center
            )

            Spacer()

            // 서버에 알리지 않는 임시 출구다. 앱을 다시 켜면 restore 가 온보딩으로 되돌린다
            Button {
                store.send(.finishTapped)
            } label: {
                Text("끝내기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.main)
            .controlSize(.large)
            .padding(.horizontal, CGFloat.ds.layout.margin)
            .padding(.bottom, CGFloat.ds.spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .task {
            store.send(.onAppear)
        }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingPlaceholderView(
        store: Store(initialState: OnboardingPlaceholderFeature.State()) {
            OnboardingPlaceholderFeature()
        }
    )
}

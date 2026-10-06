import SwiftUI
import ThirdParty

public struct OnboardingFlowView: View {
    @Bindable public var store: StoreOf<OnboardingFlowFeature>

    public init(store: StoreOf<OnboardingFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        // 온보딩 화면 스택은 OnboardingFlowFeature 의 path 가 소유한다
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            OnboardingPlaceholderView(store: store.scope(state: \.onboarding, action: \.onboarding))
        } destination: { _ in
            // Route 에 케이스가 없어 이 목적지는 만들어지지 않는다. 쌓일 화면이 생기면 `switch routeStore.case` 로 바꾼다
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview("OnboardingFlow") {
    OnboardingFlowView(
        store: Store(initialState: OnboardingFlowFeature.State()) {
            OnboardingFlowFeature()
        }
    )
}

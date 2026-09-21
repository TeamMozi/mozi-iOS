import SwiftUI
import ThirdParty

public struct OnboardingFlowView: View {
    @Bindable public var store: StoreOf<OnboardingFlowFeature>

    public init(store: StoreOf<OnboardingFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: pathBinding) {
            OnboardingPlaceholderView(store: store.scope(state: \.onboarding, action: \.onboarding))
                .navigationDestination(for: OnboardingFlowFeature.Route.self) { route in
                    destination(route)
                }
        }
    }

    // Route 에 케이스가 없어 이 목적지는 만들어질 수 없다. 쌓일 화면이 생기면 switch 로 바꾼다
    private func destination(_: OnboardingFlowFeature.Route) -> some View {
        EmptyView()
    }

    // 온보딩 목적지 스택은 OnboardingFlowFeature 가 소유하고, NavigationStack 이 그 path 를 그대로 민다
    private var pathBinding: Binding<[OnboardingFlowFeature.Route]> {
        Binding(
            get: { store.path },
            set: { store.send(.pathChanged($0)) }
        )
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

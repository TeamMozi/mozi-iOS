import SwiftUI
import ThirdParty

public struct OnboardingFlowView: View {
    @Bindable public var store: StoreOf<OnboardingFlowFeature>

    public init(store: StoreOf<OnboardingFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        // 온보딩 화면 스택은 OnboardingFlowFeature 의 path 가 소유한다. 뒤로 가기는 `.path(.popFrom)` 으로 들어온다
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ProfileSettingView(store: store.scope(state: \.profile, action: \.profile))
        } destination: { routeStore in
            switch routeStore.case {
            case let .interestSetting(interestStore):
                InterestSettingView(store: interestStore)
            }
        }
    }
}

// MARK: - Preview

#Preview("OnboardingFlow") {
    OnboardingFlowView(
        store: Store(initialState: OnboardingFlowFeature.State()) {
            OnboardingFlowFeature()
        } withDependencies: {
            $0.interestClient = .previewValue
            $0.userClient = .previewValue
            $0.authClient.logout = {}
        }
    )
}

import Domain
import Feature
import MoziDemoKit
import SwiftUI
import ThirdParty

/// 온보딩 흐름 전체를 띄운다. 프로필부터 「완료」 까지 넘기고, 끝나거나 로그아웃하면 처음으로 돌아간다.
///
/// 온보딩 Flow 가 자기 NavigationStack 을 가지므로 `DemoRootView` 가 전체 화면으로 덮어 띄운다.
struct OnboardingFlowDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: OnboardingFlowDemoState
    @State private var store: StoreOf<DemoOnboardingFlowFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _demoState = State(initialValue: .start)
        _store = State(initialValue: Self.makeStore())
    }

    var body: some View {
        OnboardingFlowView(store: store.scope(state: \.flow, action: \.flow))
            .id(generation)
            .demoMenu(
                shortLabel: demoState.shortTitle,
                options: OnboardingFlowDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
                selectedID: demoState.rawValue,
                onSelect: { id in
                    select(OnboardingFlowDemoState(rawValue: id) ?? .start)
                },
                onExit: onExit
            )
    }

    private func select(_ state: OnboardingFlowDemoState) {
        demoState = state
        store = Self.makeStore()
        generation += 1
    }

    private static func makeStore() -> StoreOf<DemoOnboardingFlowFeature> {
        Store(initialState: DemoOnboardingFlowFeature.State()) {
            DemoOnboardingFlowFeature()
        } withDependencies: {
            $0.interestClient = .previewValue
            $0.userClient = .previewValue
            $0.authClient = OnboardingFlowDemoState.authClient
        }
    }
}

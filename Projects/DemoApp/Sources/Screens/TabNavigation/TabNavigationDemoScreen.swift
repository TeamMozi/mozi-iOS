import Feature
import MoziDemoKit
import SwiftUI
import ThirdParty

/// 숏폼 Flow 를 고른 데모 상태로 띄운다. 상태를 고를 때마다 store 와 화면을 처음부터 다시 만든다.
///
/// 숏폼 Flow 가 자기 NavigationStack 을 가지므로 `DemoRootView` 가 전체 화면으로 덮어 띄운다.
struct TabNavigationDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: TabNavigationDemoState
    @State private var store: StoreOf<ShortformFlowFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _demoState = State(initialValue: .root)
        _store = State(initialValue: Self.makeStore(for: .root))
    }

    var body: some View {
        ShortformFlowView(store: store)
            .id(generation)
            .demoMenu(
                shortLabel: demoState.shortTitle,
                options: TabNavigationDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
                selectedID: demoState.rawValue,
                onSelect: { id in
                    select(TabNavigationDemoState(rawValue: id) ?? .root)
                },
                onExit: onExit
            )
    }

    private func select(_ state: TabNavigationDemoState) {
        demoState = state
        store = Self.makeStore(for: state)
        generation += 1
    }

    private static func makeStore(for state: TabNavigationDemoState) -> StoreOf<ShortformFlowFeature> {
        Store(initialState: state.shortformState) {
            ShortformFlowFeature()
        }
    }
}

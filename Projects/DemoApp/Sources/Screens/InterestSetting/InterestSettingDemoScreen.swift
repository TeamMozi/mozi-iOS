import Feature
import MoziDemoKit
import SwiftUI
import ThirdParty

/// 카테고리 설정 화면을 고른 데모 상태로 띄운다. 상태를 고를 때마다 store 와 화면을 처음부터 다시 만든다.
///
/// 툴바를 그리려고 자기 NavigationStack 으로 감싸므로 `DemoRootView` 가 전체 화면으로 덮어 띄운다.
struct InterestSettingDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: InterestSettingDemoState
    @State private var store: StoreOf<InterestSettingFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _demoState = State(initialValue: .idle)
        _store = State(initialValue: Self.makeStore(for: .idle))
    }

    var body: some View {
        NavigationStack {
            InterestSettingView(store: store)
        }
        .id(generation)
        .demoMenu(
            shortLabel: demoState.shortTitle,
            options: InterestSettingDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
            selectedID: demoState.rawValue,
            onSelect: { id in
                select(InterestSettingDemoState(rawValue: id) ?? .idle)
            },
            onExit: onExit
        )
    }

    private func select(_ state: InterestSettingDemoState) {
        demoState = state
        store = Self.makeStore(for: state)
        generation += 1
    }

    private static func makeStore(for state: InterestSettingDemoState) -> StoreOf<InterestSettingFeature> {
        Store(initialState: state.interestState) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient = InterestSettingDemoClient.interestClient(for: state)
            $0.userClient = InterestSettingDemoClient.userClient(for: state)
        }
    }
}

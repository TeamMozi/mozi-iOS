import Feature
import MoziDemoKit
import SwiftUI
import ThirdParty

/// 프로필 설정 화면을 고른 데모 상태로 띄운다. 상태를 고를 때마다 store 와 화면을 처음부터 다시 만든다.
///
/// 툴바(뒤로)를 그리려고 자기 NavigationStack 으로 감싸므로 `DemoRootView` 가 전체 화면으로 덮어 띄운다.
struct ProfileSettingDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: ProfileSettingDemoState
    @State private var store: StoreOf<ProfileSettingFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _demoState = State(initialValue: .empty)
        _store = State(initialValue: Self.makeStore(for: .empty))
    }

    var body: some View {
        NavigationStack {
            ProfileSettingView(store: store)
        }
        .id(generation)
        .demoMenu(
            shortLabel: demoState.shortTitle,
            options: ProfileSettingDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
            selectedID: demoState.rawValue,
            onSelect: { id in
                select(ProfileSettingDemoState(rawValue: id) ?? .empty)
            },
            onExit: onExit
        )
    }

    private func select(_ state: ProfileSettingDemoState) {
        demoState = state
        store = Self.makeStore(for: state)
        generation += 1
    }

    private static func makeStore(for state: ProfileSettingDemoState) -> StoreOf<ProfileSettingFeature> {
        Store(initialState: state.profileState) {
            ProfileSettingFeature()
        }
    }
}

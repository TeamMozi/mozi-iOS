import Feature
import MoziDemoKit
import SwiftUI
import ThirdParty

/// 로그인 화면을 고른 데모 상태로 띄운다. 상태를 고를 때마다 store 와 화면을 처음부터 다시 만든다.
struct LoginDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: LoginDemoState
    @State private var store: StoreOf<LoginFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _demoState = State(initialValue: .idle)
        _store = State(initialValue: Self.makeStore(for: .idle))
    }

    var body: some View {
        LoginView(store: store)
            .id(generation)
            .demoMenu(
                shortLabel: demoState.shortTitle,
                options: LoginDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
                selectedID: demoState.rawValue,
                onSelect: { id in
                    select(LoginDemoState(rawValue: id) ?? .idle)
                },
                onExit: onExit
            )
    }

    private func select(_ state: LoginDemoState) {
        demoState = state
        store = Self.makeStore(for: state)
        generation += 1
    }

    private static func makeStore(for state: LoginDemoState) -> StoreOf<LoginFeature> {
        Store(initialState: state.loginState) {
            LoginFeature()
        } withDependencies: {
            $0.authClient = LoginDemoAuthClient.make(for: state)
        }
    }
}

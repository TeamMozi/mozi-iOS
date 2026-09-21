import SwiftUI
import ThirdParty

public struct MyPageFlowView: View {
    @Bindable public var store: StoreOf<MyPageFlowFeature>

    public init(store: StoreOf<MyPageFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: pathBinding) {
            MyPagePlaceholderView(store: store.scope(state: \.myPage, action: \.myPage))
                .navigationDestination(for: MyPageFlowFeature.Route.self) { route in
                    destination(route)
                }
        }
    }

    // Route 에 케이스가 없어 이 목적지는 만들어질 수 없다. 쌓일 화면이 생기면 switch 로 바꾼다
    private func destination(_: MyPageFlowFeature.Route) -> some View {
        EmptyView()
    }

    // 마이 목적지 스택은 MyPageFlowFeature 가 소유하고, NavigationStack 이 그 path 를 그대로 민다
    private var pathBinding: Binding<[MyPageFlowFeature.Route]> {
        Binding(
            get: { store.path },
            set: { store.send(.pathChanged($0)) }
        )
    }
}

// MARK: - Preview

#Preview("MyPageFlow") {
    MyPageFlowView(
        store: Store(initialState: MyPageFlowFeature.State()) {
            MyPageFlowFeature()
        } withDependencies: {
            $0.authClient.logout = {}
        }
    )
}

import SwiftUI
import ThirdParty

public struct ShortformFlowView: View {
    @Bindable public var store: StoreOf<ShortformFlowFeature>

    public init(store: StoreOf<ShortformFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: pathBinding) {
            PlaceholderView(store: store.scope(state: \.placeholder, action: \.placeholder))
                .navigationDestination(for: ShortformFlowFeature.Route.self) { route in
                    destination(route)
                }
        }
    }

    // Route 에 케이스가 없어 이 목적지는 만들어질 수 없다. 쌓일 화면이 생기면 switch 로 바꾼다
    private func destination(_: ShortformFlowFeature.Route) -> some View {
        EmptyView()
    }

    // 숏폼 목적지 스택은 ShortformFlowFeature 가 소유하고, NavigationStack 이 그 path 를 그대로 민다
    private var pathBinding: Binding<[ShortformFlowFeature.Route]> {
        Binding(
            get: { store.path },
            set: { store.send(.pathChanged($0)) }
        )
    }
}

// MARK: - Preview

#Preview("ShortformFlow") {
    ShortformFlowView(
        store: Store(initialState: ShortformFlowFeature.State()) {
            ShortformFlowFeature()
        }
    )
}

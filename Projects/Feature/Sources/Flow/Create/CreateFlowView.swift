import SwiftUI
import ThirdParty

public struct CreateFlowView: View {
    @Bindable public var store: StoreOf<CreateFlowFeature>

    public init(store: StoreOf<CreateFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: pathBinding) {
            PlaceholderView(store: store.scope(state: \.placeholder, action: \.placeholder))
                .navigationDestination(for: CreateFlowFeature.Route.self) { route in
                    destination(route)
                }
        }
    }

    // Route 에 케이스가 없어 이 목적지는 만들어질 수 없다. 쌓일 화면이 생기면 switch 로 바꾼다
    private func destination(_: CreateFlowFeature.Route) -> some View {
        EmptyView()
    }

    // 생성 목적지 스택은 CreateFlowFeature 가 소유하고, NavigationStack 이 그 path 를 그대로 민다
    private var pathBinding: Binding<[CreateFlowFeature.Route]> {
        Binding(
            get: { store.path },
            set: { store.send(.pathChanged($0)) }
        )
    }
}

// MARK: - Preview

#Preview("CreateFlow") {
    CreateFlowView(
        store: Store(initialState: CreateFlowFeature.State()) {
            CreateFlowFeature()
        }
    )
}

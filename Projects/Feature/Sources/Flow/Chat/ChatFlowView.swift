import SwiftUI
import ThirdParty

public struct ChatFlowView: View {
    @Bindable public var store: StoreOf<ChatFlowFeature>

    public init(store: StoreOf<ChatFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: pathBinding) {
            PlaceholderView(store: store.scope(state: \.placeholder, action: \.placeholder))
                .navigationDestination(for: ChatFlowFeature.Route.self) { route in
                    destination(route)
                }
        }
    }

    // Route 에 케이스가 없어 이 목적지는 만들어질 수 없다. 쌓일 화면이 생기면 switch 로 바꾼다
    private func destination(_: ChatFlowFeature.Route) -> some View {
        EmptyView()
    }

    // 대화 목적지 스택은 ChatFlowFeature 가 소유하고, NavigationStack 이 그 path 를 그대로 민다
    private var pathBinding: Binding<[ChatFlowFeature.Route]> {
        Binding(
            get: { store.path },
            set: { store.send(.pathChanged($0)) }
        )
    }
}

// MARK: - Preview

#Preview("ChatFlow") {
    ChatFlowView(
        store: Store(initialState: ChatFlowFeature.State()) {
            ChatFlowFeature()
        }
    )
}

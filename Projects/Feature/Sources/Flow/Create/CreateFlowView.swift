import SwiftUI
import ThirdParty

public struct CreateFlowView: View {
    @Bindable public var store: StoreOf<CreateFlowFeature>

    public init(store: StoreOf<CreateFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        // 생성 화면 스택은 CreateFlowFeature 의 path 가 소유한다
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            PlaceholderView(store: store.scope(state: \.placeholder, action: \.placeholder))
        } destination: { _ in
            // Route 에 케이스가 없어 이 목적지는 만들어지지 않는다. 쌓일 화면이 생기면 `switch routeStore.case` 로 바꾼다
            EmptyView()
        }
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

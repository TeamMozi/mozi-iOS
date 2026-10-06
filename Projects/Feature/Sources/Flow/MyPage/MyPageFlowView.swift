import SwiftUI
import ThirdParty

public struct MyPageFlowView: View {
    @Bindable public var store: StoreOf<MyPageFlowFeature>

    public init(store: StoreOf<MyPageFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        // 마이 화면 스택은 MyPageFlowFeature 의 path 가 소유한다
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            MyPagePlaceholderView(store: store.scope(state: \.myPage, action: \.myPage))
        } destination: { _ in
            // Route 에 케이스가 없어 이 목적지는 만들어지지 않는다. 쌓일 화면이 생기면 `switch routeStore.case` 로 바꾼다
            EmptyView()
        }
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

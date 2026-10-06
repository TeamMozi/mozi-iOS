import SwiftUI
import ThirdParty

public struct ShortformFlowView: View {
    @Bindable public var store: StoreOf<ShortformFlowFeature>

    public init(store: StoreOf<ShortformFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        // 숏폼 화면 스택은 ShortformFlowFeature 의 path 가 소유한다. 뒤로 가기는 `.path(.popFrom)` 으로 들어온다
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            PlaceholderView(store: store.scope(state: \.placeholder, action: \.placeholder))
        } destination: { routeStore in
            switch routeStore.case {
            case let .sample(sampleStore):
                NavigationSampleView(store: sampleStore)
            }
        }
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

#Preview("ShortformFlow / 견본 2장") {
    ShortformFlowView(
        store: Store(initialState: twoSamplesState()) {
            ShortformFlowFeature()
        }
    )
}

// #Preview 안에서는 @Reducer 가 만든 `Route.State.sample` 을 찾지 못해 밖에서 만든다
private func twoSamplesState() -> ShortformFlowFeature.State {
    ShortformFlowFeature.State(
        path: StackState([
            .sample(NavigationSampleFeature.State(number: 1)),
            .sample(NavigationSampleFeature.State(number: 2)),
        ])
    )
}

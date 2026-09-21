import SwiftUI
import ThirdParty

public struct PlaceholderView: View {
    @Bindable public var store: StoreOf<PlaceholderFeature>

    public init(store: StoreOf<PlaceholderFeature>) {
        self.store = store
    }

    public var body: some View {
        Text(store.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                store.send(.onAppear)
            }
    }
}

// MARK: - Preview

#Preview("Placeholder / Shortform") {
    PlaceholderView(
        store: Store(initialState: PlaceholderFeature.State(title: "Shortform")) {
            PlaceholderFeature()
        }
    )
}

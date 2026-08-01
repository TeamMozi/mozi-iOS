import SwiftUI
import ThirdParty

public struct PlaceholderView: View {
    @Bindable public var store: StoreOf<PlaceholderFeature>

    public init(store: StoreOf<PlaceholderFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Mozi")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                store.send(.onAppear)
            }
    }
}

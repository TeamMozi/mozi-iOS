import Feature
import SwiftUI
import ThirdParty

enum CompositionRoot {
    @MainActor
    static func makeRootStore(infra: InfraContainer) -> StoreOf<RootFeature> {
        AppBootstrap.run(infra)
        return Store(initialState: RootFeature.State()) {
            RootFeature()
        }
    }

    @MainActor
    static func rootView(store: StoreOf<RootFeature>) -> some View {
        RootView(store: store)
    }
}

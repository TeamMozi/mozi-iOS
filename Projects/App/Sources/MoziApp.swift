import CoreSocialAuth
import Feature
import SwiftUI
import ThirdParty

@main
struct MoziApp: App {
    private let store: StoreOf<RootFeature>

    init() {
        store = CompositionRoot.makeRootStore()
    }

    var body: some Scene {
        WindowGroup {
            CompositionRoot.rootView(store: store)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    if KakaoAuthRedirectHandler.handle(url: url) {
                        return
                    }
                    store.send(.appCoordinator(.deepLinkReceived(url)))
                }
        }
    }
}

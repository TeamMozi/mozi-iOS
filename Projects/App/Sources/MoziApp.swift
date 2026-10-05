import CoreSocialAuth
import Feature
import SharedDesignSystem
import SwiftUI
import ThirdParty

@main
struct MoziApp: App {
    private let store: StoreOf<RootFeature>

    init() {
        DesignNavigationBar.applyBackIndicator()
        store = CompositionRoot.makeRootStore()
    }

    var body: some Scene {
        WindowGroup {
            CompositionRoot.rootView(store: store)
                .onOpenURL { url in
                    if KakaoAuthRedirectHandler.handle(url: url) {
                        return
                    }
                    store.send(.rootFlow(.deepLinkReceived(url)))
                }
        }
    }
}

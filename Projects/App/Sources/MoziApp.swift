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
        let infra = InfraContainer.make()
        store = CompositionRoot.makeRootStore(infra: infra)
    }

    var body: some Scene {
        WindowGroup {
            CompositionRoot.rootView(store: store)
                .onOpenURL { url in
                    if SocialAuthRedirectHandler.handle(url: url) {
                        return
                    }
                    store.send(.rootFlow(.deepLinkReceived(url)))
                }
        }
    }
}

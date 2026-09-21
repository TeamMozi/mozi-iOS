import SwiftUI
import ThirdParty

public struct MainTabView: View {
    @Bindable public var store: StoreOf<MainTabFeature>

    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            ShortformFlowView(store: store.scope(state: \.shortform, action: \.shortform))
                .tabItem { Image(systemName: "play.circle") }
                .tag(MainTabFeature.Tab.shortform)

            SearchFlowView(store: store.scope(state: \.search, action: \.search))
                .tabItem { Image(systemName: "magnifyingglass") }
                .tag(MainTabFeature.Tab.search)

            ChatFlowView(store: store.scope(state: \.chat, action: \.chat))
                .tabItem { Image(systemName: "message") }
                .tag(MainTabFeature.Tab.chat)

            MyPageFlowView(store: store.scope(state: \.myPage, action: \.myPage))
                .tabItem { Image(systemName: "person") }
                .tag(MainTabFeature.Tab.myPage)

            CreateFlowView(store: store.scope(state: \.create, action: \.create))
                .tabItem { Image(systemName: "plus") }
                .tag(MainTabFeature.Tab.create)
        }
    }
}

// MARK: - Preview

#Preview("MainTab") {
    MainTabView(
        store: Store(initialState: MainTabFeature.State()) {
            MainTabFeature()
        } withDependencies: {
            $0.authClient.logout = {}
        }
    )
}

import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct MainTabView: View {
    @Bindable public var store: StoreOf<MainTabFeature>
    @Environment(\.colorScheme) private var colorScheme

    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            ShortformFlowView(store: store.scope(state: \.shortform, action: \.shortform))
                .tabItem { tabIcon(.shortform) }
                .tag(MainTabFeature.Tab.shortform)

            SearchFlowView(store: store.scope(state: \.search, action: \.search))
                .tabItem { tabIcon(.search) }
                .tag(MainTabFeature.Tab.search)

            ChatFlowView(store: store.scope(state: \.chat, action: \.chat))
                .tabItem { tabIcon(.chat) }
                .tag(MainTabFeature.Tab.chat)

            MyPageFlowView(store: store.scope(state: \.myPage, action: \.myPage))
                .tabItem { tabIcon(.myPage) }
                .tag(MainTabFeature.Tab.myPage)

            CreateFlowView(store: store.scope(state: \.create, action: \.create))
                .tabItem { tabIcon(.create) }
                .tag(MainTabFeature.Tab.create)
        }
    }

    // 아이콘 색을 그림에 입혀 두므로 탭바에 `.tint` 를 걸지 않는다. 탭 안 화면의 강조색은 그대로다.
    private func tabIcon(_ tab: MainTabFeature.Tab) -> Image {
        tab.tabBarIcon.image(isSelected: store.selectedTab == tab, colorScheme: colorScheme)
    }
}

extension MainTabFeature.Tab {
    /// 탭바 아이콘. 숏폼은 Figma `icon/play` 인 `playStack` 이다.
    var tabBarIcon: TabBarIcon {
        switch self {
        case .shortform: .playStack
        case .search: .search
        case .chat: .chat
        case .myPage: .person
        case .create: .plus
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

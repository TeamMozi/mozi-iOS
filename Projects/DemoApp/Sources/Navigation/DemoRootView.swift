import MoziDemoKit
import SwiftUI

/// 데모 앱 최상위. 첫 화면 → 흐름 → 화면 순서로 쌓고, 「목록으로 돌아가기」는 첫 화면까지 비운다.
///
/// 자기 NavigationStack 을 가진 화면(`DemoScreen.presentsFullScreen`)은 쌓지 않고 전체 화면으로 덮어 띄운다.
struct DemoRootView: View {
    let buildInfo: DemoBuildInfo

    @State private var path: [DemoRoute] = []
    @State private var coveredScreen: DemoScreen?

    var body: some View {
        NavigationStack(path: $path) {
            DemoHomeView(buildInfo: buildInfo) { route in
                path.append(route)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: DemoRoute.self) { route in
                destination(for: route)
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .fullScreenCover(item: $coveredScreen) { screen in
            screenView(screen)
        }
    }

    @ViewBuilder
    private func destination(for route: DemoRoute) -> some View {
        switch route {
        case let .flow(flow):
            DemoFlowView(
                flow: flow,
                onBack: goBack,
                onOpen: openScreen
            )
        case let .screen(screen):
            screenView(screen)
        case let .gallery(screen):
            galleryView(screen)
                .demoMenu(
                    shortLabel: nil,
                    options: [],
                    selectedID: nil,
                    onSelect: { _ in },
                    onExit: backToList
                )
        }
    }

    @ViewBuilder
    private func screenView(_ screen: DemoScreen) -> some View {
        switch screen {
        case .login:
            LoginDemoScreen(onExit: backToList)
        case .tabNavigation:
            TabNavigationDemoScreen(onExit: backToList)
        }
    }

    @ViewBuilder
    private func galleryView(_ screen: GalleryScreen) -> some View {
        switch screen {
        case .color:
            ColorGalleryView()
        case .typography:
            TypographyGalleryView()
        case .button:
            ButtonGalleryView()
        case .screenStatus:
            ScreenStatusGalleryView()
        case .input:
            InputGalleryView()
        case .frameParts:
            FramePartsGalleryView()
        }
    }

    // 최상위 NavigationStack 안에 Flow 의 NavigationStack 이 겹치면 뒤로 가기가 꼬인다
    private func openScreen(_ screen: DemoScreen) {
        if screen.presentsFullScreen {
            coveredScreen = screen
        } else {
            path.append(.screen(screen))
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func backToList() {
        coveredScreen = nil
        path.removeAll()
    }
}

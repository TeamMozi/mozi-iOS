import SwiftUI

/// 데모 앱 최상위. 첫 화면 → 흐름 → 화면 순서로 쌓고, 「목록으로 돌아가기」는 첫 화면까지 비운다.
struct DemoRootView: View {
    let buildInfo: DemoBuildInfo

    @State private var path: [DemoRoute] = []

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
    }

    @ViewBuilder
    private func destination(for route: DemoRoute) -> some View {
        switch route {
        case let .flow(flow):
            DemoFlowView(
                flow: flow,
                onBack: goBack,
                onOpen: { screen in
                    path.append(.screen(screen))
                }
            )
        case let .screen(screen):
            screenView(screen)
        case .gallery:
            DesignSystemGalleryView()
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
        }
    }

    private func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func backToList() {
        path.removeAll()
    }
}

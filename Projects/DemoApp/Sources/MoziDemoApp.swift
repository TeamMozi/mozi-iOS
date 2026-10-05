import SharedDesignSystem
import SwiftUI

@main
struct MoziDemoApp: App {
    init() {
        DesignNavigationBar.applyBackIndicator()
    }

    var body: some Scene {
        WindowGroup {
            DemoRootView(buildInfo: .current)
        }
    }
}

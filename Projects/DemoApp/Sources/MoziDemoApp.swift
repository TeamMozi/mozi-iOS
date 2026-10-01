import SharedDesignSystem
import SwiftUI

@main
struct MoziDemoApp: App {
    init() {
        _ = DesignSystemFontRegistration.registerIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            DemoRootView(buildInfo: .current)
                .preferredColorScheme(.dark)
        }
    }
}

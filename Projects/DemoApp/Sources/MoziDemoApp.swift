import SwiftUI

@main
struct MoziDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoRootView(buildInfo: .current)
        }
    }
}

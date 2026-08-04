import Foundation
import SharedDesignSystem
import SharedLogger
import ThirdParty

enum AppBootstrap {
    @MainActor
    static func run() {
        _ = DesignSystemFontRegistration.registerIfNeeded()
        let infra = InfraContainer.live()
        prepareDependencies {
            Dependencies.register(&$0, infra: infra)
        }
        Logger.shared.info("App bootstrap completed", category: .general)
    }
}

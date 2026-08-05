import CoreStorage
import Foundation

/// App 인프라 컨테이너. 설정과 로컬 저장소만 보유한다.
struct InfraContainer: Sendable {
    let configuration: AppConfiguration
    let userDefaults: any UserDefaultsStorage
    let keychain: any KeychainStorage
}

extension InfraContainer {
    @MainActor
    static func live() -> InfraContainer {
        let configuration = AppConfiguration.make()
        return InfraContainer(
            configuration: configuration,
            userDefaults: DefaultUserDefaultsStorage(
                suiteName: configuration.bundleID
            ),
            keychain: DefaultKeychainStorage(
                service: configuration.bundleID
            )
        )
    }
}

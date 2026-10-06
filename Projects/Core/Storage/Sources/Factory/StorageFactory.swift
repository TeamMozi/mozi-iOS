import Foundation

/// CoreStorage 의 유일한 생성 창구. 필요한 저장소만 만든다.
public enum StorageFactory {
    public static func makeKeychain(config: StorageConfiguration) -> any KeychainStorage {
        DefaultKeychainStorage(service: config.keychainService)
    }

    public static func makeUserDefaults(config: StorageConfiguration) -> any UserDefaultsStorage {
        DefaultUserDefaultsStorage(suiteName: config.userDefaultsSuiteName)
    }
}

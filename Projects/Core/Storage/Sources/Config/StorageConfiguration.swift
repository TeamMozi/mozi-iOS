import Foundation

public struct StorageConfiguration: Sendable {
    /// 키체인 항목의 `kSecAttrService`. 기본값을 두지 않는다. App 이 Bundle ID 를 넣는다.
    public let keychainService: String
    /// nil 이면 `UserDefaults.standard` 를 쓴다.
    public let userDefaultsSuiteName: String?

    public init(keychainService: String, userDefaultsSuiteName: String? = nil) {
        self.keychainService = keychainService
        self.userDefaultsSuiteName = userDefaultsSuiteName
    }
}

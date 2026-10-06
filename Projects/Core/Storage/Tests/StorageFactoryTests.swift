@testable import CoreStorage
import XCTest

final class StorageFactoryTests: XCTestCase {
    func test_makeKeychain은_설정의_keychainService를_쓴다() async throws {
        let storage = try XCTUnwrap(
            StorageFactory.makeKeychain(
                config: StorageConfiguration(keychainService: "com.teamMozi.tests.storage.keychain")
            ) as? DefaultKeychainStorage
        )

        let service = await storage.service
        XCTAssertEqual(service, "com.teamMozi.tests.storage.keychain")
    }

    func test_makeUserDefaults는_설정의_suite에_저장한다() async throws {
        let suiteName = "com.teamMozi.tests.storage.defaults"
        let key = "com.teamMozi.tests.storage.suiteFlag"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        UserDefaults.standard.removeObject(forKey: key)
        let storage = StorageFactory.makeUserDefaults(
            config: StorageConfiguration(
                keychainService: "com.teamMozi.tests.storage.unused",
                userDefaultsSuiteName: suiteName
            )
        )

        await storage.setBool(true, forKey: key)

        XCTAssertTrue(defaults.bool(forKey: key))
        XCTAssertFalse(UserDefaults.standard.bool(forKey: key))
        defaults.removePersistentDomain(forName: suiteName)
    }

    func test_makeUserDefaults는_suite가_없으면_standard에_저장한다() async {
        let key = "com.teamMozi.tests.storage.standardFlag"
        UserDefaults.standard.removeObject(forKey: key)
        let storage = StorageFactory.makeUserDefaults(
            config: StorageConfiguration(keychainService: "com.teamMozi.tests.storage.unused")
        )

        await storage.setBool(true, forKey: key)

        XCTAssertTrue(UserDefaults.standard.bool(forKey: key))
        UserDefaults.standard.removeObject(forKey: key)
    }
}

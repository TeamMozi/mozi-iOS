import CoreStorage
import Foundation

actor FailingKeychainStorage: KeychainStorage {
    enum Operation: Sendable {
        case get
        case delete
        case save
    }

    private let failingOperations: Set<Operation>

    init(failingOperations: Set<Operation>) {
        self.failingOperations = failingOperations
    }

    func save(_ value: some Codable & Sendable, forKey key: String) async throws {
        if failingOperations.contains(.save) {
            throw KeychainError.saveFailed(status: -1)
        }
    }

    func get<T: Codable & Sendable>(forKey key: String) async throws -> T? {
        if failingOperations.contains(.get) {
            throw KeychainError.loadFailed(status: -1)
        }
        return nil
    }

    func delete(forKey key: String) async throws {
        if failingOperations.contains(.delete) {
            throw KeychainError.deleteFailed(status: -1)
        }
    }

    func deleteAll() async throws {
        if failingOperations.contains(.delete) {
            throw KeychainError.deleteFailed(status: -1)
        }
    }
}

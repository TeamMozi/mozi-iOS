import CoreStorage
import Foundation

actor InMemoryKeychainStorage: KeychainStorage {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func save(_ value: some Codable & Sendable, forKey key: String) async throws {
        storage[key] = try encoder.encode(value)
    }

    func get<T: Codable & Sendable>(forKey key: String) async throws -> T? {
        guard let data = storage[key] else { return nil }
        return try decoder.decode(T.self, from: data)
    }

    func delete(forKey key: String) async throws {
        storage[key] = nil
    }

    func deleteAll() async throws {
        storage.removeAll()
    }
}

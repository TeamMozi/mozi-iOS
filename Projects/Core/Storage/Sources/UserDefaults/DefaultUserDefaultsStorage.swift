import Foundation

actor DefaultUserDefaultsStorage: UserDefaultsStorage {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(suiteName: String? = nil) {
        self.defaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    func save(_ value: some Codable & Sendable, forKey key: String) async throws {
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw UserDefaultsError.encodingFailed
        }
        defaults.set(data, forKey: key)
    }

    func get<T: Codable & Sendable>(forKey key: String) async throws -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw UserDefaultsError.decodingFailed
        }
    }

    func delete(forKey key: String) async throws {
        defaults.removeObject(forKey: key)
    }

    func setBool(_ value: Bool, forKey key: String) async {
        defaults.set(value, forKey: key)
    }

    func bool(forKey key: String) async -> Bool {
        defaults.bool(forKey: key)
    }
}

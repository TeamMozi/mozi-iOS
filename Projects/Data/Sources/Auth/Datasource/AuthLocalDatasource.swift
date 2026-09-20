import CoreNetwork
import CoreStorage
import Foundation

public struct AuthLocalDatasource: TokenProviding {
    private let keychain: any KeychainStorage
    private let sessionKey: String

    public init(keychain: any KeychainStorage, sessionKey: String = "auth.session") {
        self.keychain = keychain
        self.sessionKey = sessionKey
    }

    func save(_ dto: AuthSessionStorageDTO) async throws {
        try await keychain.save(dto, forKey: sessionKey)
    }

    func load() async throws -> AuthSessionStorageDTO? {
        try await keychain.get(forKey: sessionKey)
    }

    func clear() async throws {
        try await keychain.delete(forKey: sessionKey)
    }

    public func accessToken() async throws -> String? {
        try await load()?.accessToken
    }
}

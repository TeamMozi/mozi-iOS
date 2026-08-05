import CoreNetwork
import CoreStorage
import Domain
import Foundation

public struct AuthLocalDatasource: TokenProviding {
    private let keychain: any KeychainStorage
    private let sessionKey: String

    public init(keychain: any KeychainStorage, sessionKey: String = "auth.session") {
        self.keychain = keychain
        self.sessionKey = sessionKey
    }

    public func save(_ session: AuthSession) async throws {
        try await keychain.save(session, forKey: sessionKey)
    }

    public func load() async throws -> AuthSession? {
        try await keychain.get(forKey: sessionKey)
    }

    public func clear() async throws {
        try await keychain.delete(forKey: sessionKey)
    }

    public func accessToken() async throws -> String? {
        try await load()?.accessToken
    }
}

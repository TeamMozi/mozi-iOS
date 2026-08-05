import CoreNetwork
import CoreStorage
import Domain
import Foundation

public struct AuthRepositoryImpl: Sendable {
    private let remote: AuthRemoteDatasource
    private let local: AuthLocalDatasource

    public init(remote: AuthRemoteDatasource, local: AuthLocalDatasource) {
        self.remote = remote
        self.local = local
    }

    public func restoreSession() async throws -> AuthSession? {
        do {
            return try await local.load()
        } catch {
            throw mapStorageError(error)
        }
    }

    public func currentSession() async -> AuthSession? {
        try? await local.load()
    }

    public func loginWithKakao(accessToken: String) async throws -> AuthSession {
        do {
            let dto = try await remote.loginWithKakao(accessToken: accessToken)
            return try await saveLoginSession(dto)
        } catch {
            throw mapLoginError(error)
        }
    }

    public func loginWithApple(identityToken: String) async throws -> AuthSession {
        do {
            let dto = try await remote.loginWithApple(identityToken: identityToken)
            return try await saveLoginSession(dto)
        } catch {
            throw mapLoginError(error)
        }
    }

    public func loginWithDev() async throws -> AuthSession {
        do {
            let dto = try await remote.loginWithDev()
            return try await saveLoginSession(dto)
        } catch {
            throw mapLoginError(error)
        }
    }

    public func logout() async throws {
        do {
            try await remote.logout()
        } catch {
            // 원격 실패와 무관하게 로컬 세션 삭제
        }

        do {
            try await local.clear()
        } catch {
            throw mapStorageError(error)
        }
    }

    private func saveLoginSession(_ dto: LoginResponseDTO) async throws -> AuthSession {
        let session = dto.toDomain()
        do {
            try await local.save(session)
            return session
        } catch {
            throw mapStorageError(error)
        }
    }

    private func mapLoginError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }

        if error is KeychainError {
            return mapStorageError(error)
        }

        guard let networkError = error as? NetworkError else {
            return .unknown(message: String(describing: error))
        }

        switch networkError {
        case .transport:
            return .network
        case .unauthorized, .badRequest:
            return .loginFailed
        default:
            return .unknown(message: String(describing: networkError))
        }
    }

    private func mapStorageError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        return .storage(message: String(describing: error))
    }
}

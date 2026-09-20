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
            guard let stored = try await local.load() else {
                return nil
            }
            return AuthDTOMapper.domain(from: stored)
        } catch {
            throw AuthErrorMapper.storage(error)
        }
    }

    public func currentSession() async -> AuthSession? {
        guard let stored = try? await local.load() else {
            return nil
        }
        return AuthDTOMapper.domain(from: stored)
    }

    public func loginWithKakao(accessToken: String) async throws -> AuthSession {
        do {
            let dto = try await remote.loginWithKakao(accessToken: accessToken)
            return try await saveLoginSession(dto)
        } catch {
            throw AuthErrorMapper.login(error)
        }
    }

    public func loginWithApple(identityToken: String) async throws -> AuthSession {
        do {
            let dto = try await remote.loginWithApple(identityToken: identityToken)
            return try await saveLoginSession(dto)
        } catch {
            throw AuthErrorMapper.login(error)
        }
    }

    public func loginWithDev() async throws -> AuthSession {
        do {
            let dto = try await remote.loginWithDev()
            return try await saveLoginSession(dto)
        } catch {
            throw AuthErrorMapper.login(error)
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
            throw AuthErrorMapper.storage(error)
        }
    }

    /// 오류를 바꾸지 않고 그대로 던진다. 로그인 메서드의 catch 가 한 번만 바꾼다.
    private func saveLoginSession(_ dto: LoginResponseDTO) async throws -> AuthSession {
        try await local.save(AuthDTOMapper.storage(from: dto))
        return AuthDTOMapper.domain(from: dto)
    }
}

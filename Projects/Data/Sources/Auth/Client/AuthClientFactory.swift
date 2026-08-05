import Domain
import Foundation

public enum AuthClientFactory {
    public static func make(
        repository: AuthRepositoryImpl,
        credentialProvider: @escaping @Sendable (AuthProvider) async throws -> String
    ) -> AuthClient {
        AuthClient(
            restoreSession: {
                try await repository.restoreSession()
            },
            login: { provider in
                let credential = try await credentialProvider(provider)
                switch provider {
                case .kakao:
                    return try await repository.loginWithKakao(accessToken: credential)
                case .apple:
                    return try await repository.loginWithApple(identityToken: credential)
                }
            },
            logout: {
                try await repository.logout()
            },
            currentSession: {
                await repository.currentSession()
            }
        )
    }
}

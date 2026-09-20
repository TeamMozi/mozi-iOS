import Domain
import Foundation

public enum AuthClientFactory {
    public static func make(session: AuthSessionAssembly) -> AuthClient {
        makeClient(
            repository: makeRepository(session: session),
            session: session
        )
    }

    private static func makeRepository(session: AuthSessionAssembly) -> AuthRepositoryImpl {
        AuthRepositoryImpl(
            remote: AuthRemoteDatasource(
                plainClient: session.plainClient,
                authedClient: session.authedClient
            ),
            local: session.local
        )
    }

    private static func makeClient(
        repository: AuthRepositoryImpl,
        session: AuthSessionAssembly
    ) -> AuthClient {
        let services = session.socialAuthServices
        return AuthClient(
            restoreSession: {
                try await repository.restoreSession()
            },
            login: { provider in
                let credential = try await SocialAuthCredentialProvider.credential(
                    for: provider,
                    services: services
                )
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

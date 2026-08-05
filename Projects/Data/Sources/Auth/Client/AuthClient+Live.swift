import CoreNetwork
import CoreSocialAuth
import CoreStorage
import Domain
import Foundation

public extension AuthClient {
    /// Auth live 조립. plain refresh 경로로 refresher를 먼저 만들어 순환 의존을 끊는다.
    static func live(
        baseURL: URL,
        keychain: any KeychainStorage,
        socialAuthServices: SocialAuthServices
    ) -> AuthClient {
        let networkConfiguration = NetworkConfiguration(baseURL: baseURL)
        let plainNetworkClient = DefaultNetworkClient.plain(
            configuration: networkConfiguration
        )
        let local = AuthLocalDatasource(keychain: keychain)

        // refresh는 plain only. logout 경로가 없어 authed 자리에 plain을 넣는다.
        let refreshRemote = AuthRemoteDatasource(
            plainClient: plainNetworkClient,
            authedClient: plainNetworkClient
        )
        let tokenRefresher = AuthTokenRefresher(
            remote: refreshRemote,
            local: local
        )
        let authedNetworkClient = DefaultNetworkClient.authed(
            configuration: networkConfiguration,
            tokenProvider: local,
            tokenRefresher: tokenRefresher
        )
        let fullRemote = AuthRemoteDatasource(
            plainClient: plainNetworkClient,
            authedClient: authedNetworkClient
        )
        let repository = AuthRepositoryImpl(
            remote: fullRemote,
            local: local
        )

        return AuthClientFactory.make(
            repository: repository,
            credentialProvider: { provider in
                try await SocialAuthCredentialProvider.credential(
                    for: provider,
                    services: socialAuthServices
                )
            }
        )
    }
}

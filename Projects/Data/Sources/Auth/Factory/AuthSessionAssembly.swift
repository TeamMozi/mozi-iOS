import CoreNetwork
import CoreSocialAuth
import CoreStorage
import Foundation

/// 인증 창구들이 나눠 쓰는 조립 결과.
/// 인증 클라이언트를 한 번만 만들어 토큰 재발급을 한 번만 태우는 장치를 공유한다.
public struct AuthSessionAssembly: Sendable {
    let plainClient: any NetworkClient
    let authedClient: any NetworkClient
    let local: AuthLocalDatasource
    let socialAuthServices: SocialAuthServices

    public static func make(
        keychain: any KeychainStorage,
        baseURL: URL,
        socialAuthServices: SocialAuthServices
    ) -> AuthSessionAssembly {
        let configuration = NetworkConfiguration(baseURL: baseURL)
        let plainClient = DefaultNetworkClient.plain(configuration: configuration)
        let local = AuthLocalDatasource(keychain: keychain)

        // 재발급은 평문 경로로만 나간다. 인증 자리에 평문을 넣어 순환 의존을 끊는다.
        let refreshRemote = AuthRemoteDatasource(
            plainClient: plainClient,
            authedClient: plainClient
        )
        let tokenRefresher = AuthTokenRefresher(remote: refreshRemote, local: local)
        let authedClient = DefaultNetworkClient.authed(
            configuration: configuration,
            tokenProvider: local,
            tokenRefresher: tokenRefresher
        )

        return AuthSessionAssembly(
            plainClient: plainClient,
            authedClient: authedClient,
            local: local,
            socialAuthServices: socialAuthServices
        )
    }
}

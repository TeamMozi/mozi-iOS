import CoreSocialAuth
import Data
import Domain
import ThirdParty

enum Dependencies {
    @MainActor
    static func register(
        _ values: inout DependencyValues,
        infra: InfraContainer,
        socialConfig: SocialAuthConfiguration
    ) {
        let socialAuthServices = SocialAuthServiceFactory().make(
            configuration: socialConfig
        )
        let authSession = AuthSessionAssembly.make(
            keychain: infra.keychain,
            baseURL: infra.configuration.baseURL,
            socialAuthServices: socialAuthServices
        )
        values.authClient = AuthClientFactory.make(session: authSession)
    }
}

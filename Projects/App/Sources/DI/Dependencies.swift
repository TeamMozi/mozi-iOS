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
        values.authClient = .live(
            baseURL: infra.configuration.baseURL,
            keychain: infra.keychain,
            socialAuthServices: socialAuthServices
        )
    }
}

import Data
import Domain
import ThirdParty

enum Dependencies {
    static func register(
        _ values: inout DependencyValues,
        infra: InfraContainer
    ) {
        values.authClient = .live(
            baseURL: infra.configuration.baseURL,
            keychain: infra.keychain,
            oauthServices: OAuthServiceFactory.makeStub()
        )
    }
}

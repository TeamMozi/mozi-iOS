import Data
import Domain
import ThirdParty

enum Dependencies {
    @MainActor
    static func register(
        _ values: inout DependencyValues,
        infra: InfraContainer
    ) {
        let authSession = AuthSessionAssembly.make(
            keychain: infra.keychain,
            networkConfig: infra.networkConfig,
            socialAuthServices: infra.socialAuthServices
        )
        values.authClient = AuthClientFactory.make(session: authSession)
    }
}

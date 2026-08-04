import ThirdParty

enum Dependencies {
    static func register(
        _ values: inout DependencyValues,
        infra: InfraContainer
    ) {
        // TODO: Domain Client factory 등록
        _ = infra
        _ = values
    }
}

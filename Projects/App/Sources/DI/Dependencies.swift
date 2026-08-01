import ThirdParty

enum Dependencies {
    static func register(
        _ values: inout DependencyValues,
        infra: InfraContainer
    ) {
        // 초기 domain client 없음. 이후 factory 등록 지점.
        _ = infra
        _ = values
    }
}

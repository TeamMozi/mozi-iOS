import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectFactory.app(
    .mozi,
    dependencies: [
        .feature,
        .data,
        .domain,
        .coreNetwork,
        .coreStorage,
        .coreSocialAuth,
        .sharedLogger,
        .sharedUtils,
        .sharedDesignSystem,
        .thirdParty,
        .thirdPartyUI,
        .thirdPartyCore,
    ],
    entitlements: .file(path: "Mozi.entitlements")
)

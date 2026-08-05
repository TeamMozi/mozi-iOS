import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectFactory.framework(
    .data,
    dependencies: [
        .domain,
        .coreNetwork,
        .coreStorage,
        .coreSocialAuth,
        .sharedLogger,
        .sharedUtils,
    ],
    includesTests: true,
    testsDependencies: [
        .domain,
        .coreNetwork,
        .coreStorage,
        .coreSocialAuth,
    ]
)

import ProjectDescription
import ProjectDescriptionHelpers

// Data·Core*·ThirdPartyCore 는 가져오지 않는다. authClient 는 앱 안의 가짜 응답으로 채운다.
let project = ProjectFactory.app(
    .moziDemo,
    dependencies: [
        .feature,
        .domain,
        .sharedDesignSystem,
        .thirdParty,
        .thirdPartyUI,
    ],
    includesTests: true,
    testsDependencies: [
        .feature,
        .domain,
        .thirdParty,
    ]
)

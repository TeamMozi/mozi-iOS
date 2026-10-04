import ProjectDescription
import ProjectDescriptionHelpers

// Data·Core*·ThirdPartyCore 는 가져오지 않는다. authClient 는 앱 안의 가짜 응답으로 채운다.
// 테스트가 보는 로직은 Kit/ 의 MoziDemoKit 에 두어, 테스트가 앱을 띄우지 않는다.
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
        .sharedDesignSystem,
        .thirdParty,
    ],
    kitDependencies: [
        .feature,
        .domain,
        .sharedDesignSystem,
        .thirdParty,
    ]
)

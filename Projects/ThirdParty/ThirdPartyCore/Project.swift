import ProjectDescription
import ProjectDescriptionHelpers

let project = ProjectFactory.thirdParty(
    .thirdPartyCore,
    packages: [
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .exact("2.28.0")),
    ],
    productDependencies: [
        .package(product: "KakaoSDKCommon"),
        .package(product: "KakaoSDKAuth"),
        .package(product: "KakaoSDKUser"),
    ]
)

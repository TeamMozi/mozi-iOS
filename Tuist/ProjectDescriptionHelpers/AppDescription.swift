import ProjectDescription

/// 앱 target 하나를 만드는 값 묶음. 본 앱과 데모 앱이 하나씩 갖고 `ProjectFactory.app` 이 받는다.
public struct AppDescription: Sendable {
    /// Tuist 프로젝트 이름과 폴더. `.app` → `App`, `.demoApp` → `DemoApp`.
    public let module: Module
    /// target 이름이자 실행 파일 이름(`PRODUCT_NAME`).
    public let targetName: String
    public let debugBundleID: String
    public let releaseBundleID: String
    public let debugDisplayName: String
    public let releaseDisplayName: String
    public let infoPlist: InfoPlist
    public let schemes: [AppScheme]
    /// Debug 구성에서만 쓰는 앱 아이콘 세트 이름. nil 이면 두 구성 모두 `AppIcon` 을 쓴다.
    public let debugAppIconName: String?

    public init(
        module: Module,
        targetName: String,
        debugBundleID: String,
        releaseBundleID: String,
        debugDisplayName: String,
        releaseDisplayName: String,
        infoPlist: InfoPlist,
        schemes: [AppScheme],
        debugAppIconName: String? = nil
    ) {
        self.module = module
        self.targetName = targetName
        self.debugBundleID = debugBundleID
        self.releaseBundleID = releaseBundleID
        self.debugDisplayName = debugDisplayName
        self.releaseDisplayName = releaseDisplayName
        self.infoPlist = infoPlist
        self.schemes = schemes
        self.debugAppIconName = debugAppIconName
    }
}

/// scheme 하나. 실행·분석·테스트는 `runConfiguration`, 아카이브·프로파일은 `archiveConfiguration` 을 쓴다.
public struct AppScheme: Sendable {
    public let name: String
    public let runConfiguration: ConfigurationName
    public let archiveConfiguration: ConfigurationName

    public init(
        name: String,
        runConfiguration: ConfigurationName,
        archiveConfiguration: ConfigurationName
    ) {
        self.name = name
        self.runConfiguration = runConfiguration
        self.archiveConfiguration = archiveConfiguration
    }
}

public extension AppDescription {
    /// 본 앱. 값은 앱 설명 묶음을 들이기 전과 같다.
    static let mozi = AppDescription(
        module: .app,
        targetName: ProjectEnvironment.productName,
        debugBundleID: ProjectEnvironment.AppBundle.debug,
        releaseBundleID: ProjectEnvironment.AppBundle.release,
        debugDisplayName: ProjectEnvironment.displayName + " Dev",
        releaseDisplayName: ProjectEnvironment.displayName,
        infoPlist: DefaultInfoPlist.app,
        schemes: [
            AppScheme(
                name: "Mozi-Debug",
                runConfiguration: ProjectEnvironment.debugConfigName,
                archiveConfiguration: ProjectEnvironment.debugConfigName
            ),
            AppScheme(
                name: "Mozi",
                runConfiguration: ProjectEnvironment.releaseConfigName,
                archiveConfiguration: ProjectEnvironment.releaseConfigName
            ),
        ],
        // 홈 화면에서 출시 빌드와 구별되도록 디버그 빌드는 DEV 띠가 있는 아이콘을 쓴다.
        debugAppIconName: "AppIcon-Debug"
    )

    /// 데모 앱 「모지 데모」. 두 구성이 같은 식별자·표시 이름을 쓰고 scheme 하나로 실행(Debug)과 아카이브(Release)를 한다.
    static let moziDemo = AppDescription(
        module: .demoApp,
        targetName: ProjectEnvironment.DemoApp.targetName,
        debugBundleID: ProjectEnvironment.DemoApp.bundleID,
        releaseBundleID: ProjectEnvironment.DemoApp.bundleID,
        debugDisplayName: ProjectEnvironment.DemoApp.displayName,
        releaseDisplayName: ProjectEnvironment.DemoApp.displayName,
        infoPlist: DefaultInfoPlist.demoApp,
        schemes: [
            AppScheme(
                name: ProjectEnvironment.DemoApp.schemeName,
                runConfiguration: ProjectEnvironment.debugConfigName,
                archiveConfiguration: ProjectEnvironment.releaseConfigName
            ),
        ]
    )
}

import ProjectDescription

public enum ProjectFactory {
    /// 카탈로그 기반 framework 모듈.
    public static func framework(
        _ module: Module,
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        product: Product = .staticLibrary,
        includesTests: Bool = false,
        testsDependencies: [TargetDependency] = []
    ) -> Project {
        framework(
            name: module.targetName,
            bundleIdSuffix: module.bundleIdSuffix,
            dependencies: dependencies,
            sources: sources,
            resources: resources,
            product: product,
            includesTests: includesTests,
            testsDependencies: testsDependencies
        )
    }

    /// 일반 framework/static library 모듈 생성.
    public static func framework(
        name: String,
        bundleIdSuffix: String,
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        product: Product = .staticLibrary,
        schemes: [Scheme] = [],
        includesTests: Bool = false,
        testsDependencies: [TargetDependency] = []
    ) -> Project {
        let mainTarget = Target.target(
            name: name,
            destinations: ProjectEnvironment.destinations,
            product: product,
            bundleId: ProjectEnvironment.moduleBundleId(bundleIdSuffix),
            deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
            sources: sources,
            resources: resources,
            dependencies: dependencies,
            settings: ProjectSettings.framework()
        )

        var targets = [mainTarget]
        var resolvedSchemes = schemes

        if includesTests {
            let testsName = "\(name)Tests"
            let testsTarget = Target.target(
                name: testsName,
                destinations: ProjectEnvironment.destinations,
                product: .unitTests,
                bundleId: ProjectEnvironment.moduleBundleId("\(bundleIdSuffix).tests"),
                deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
                sources: ["Tests/**"],
                dependencies: [
                    .target(name: name),
                ] + testsDependencies,
                settings: ProjectSettings.unitTests()
            )
            targets.append(testsTarget)

            if resolvedSchemes.isEmpty {
                resolvedSchemes = [
                    .scheme(
                        name: name,
                        shared: true,
                        buildAction: .buildAction(targets: [.target(name)]),
                        testAction: .targets([.testableTarget(target: .target(testsName))])
                    )
                ]
            }
        } else if resolvedSchemes.isEmpty {
            resolvedSchemes = [makeBuildScheme(name: name)]
        }

        return Project(
            name: name,
            organizationName: ProjectEnvironment.organizationName,
            settings: ProjectSettings.project(),
            targets: targets,
            schemes: resolvedSchemes
        )
    }

    /// 외부 패키지 래퍼 모듈 (ThirdParty*).
    public static func thirdParty(
        _ module: Module,
        packages: [Package],
        productDependencies: [TargetDependency],
        product: Product = .staticLibrary
    ) -> Project {
        let target = Target.target(
            name: module.targetName,
            destinations: ProjectEnvironment.destinations,
            product: product,
            bundleId: ProjectEnvironment.moduleBundleId(module.bundleIdSuffix),
            deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
            sources: ["Sources/**"],
            dependencies: productDependencies,
            settings: ProjectSettings.framework()
        )

        return Project(
            name: module.targetName,
            organizationName: ProjectEnvironment.organizationName,
            packages: packages,
            settings: ProjectSettings.project(),
            targets: [target],
            schemes: [makeBuildScheme(name: module.targetName)]
        )
    }

    public static func feature(
        dependencies: [TargetDependency],
        testsDependencies: [TargetDependency] = []
    ) -> Project {
        let featureName = Module.feature.targetName

        let featureTarget = Target.target(
            name: featureName,
            destinations: ProjectEnvironment.destinations,
            product: .framework,
            bundleId: ProjectEnvironment.moduleBundleId(Module.feature.bundleIdSuffix),
            deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
            sources: ["Sources/**"],
            dependencies: dependencies,
            settings: ProjectSettings.framework()
        )

        let testsTarget = Target.target(
            name: "FeatureTests",
            destinations: ProjectEnvironment.destinations,
            product: .unitTests,
            bundleId: ProjectEnvironment.moduleBundleId("feature.tests"),
            deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: featureName),
            ] + testsDependencies,
            settings: ProjectSettings.unitTests()
        )

        return Project(
            name: featureName,
            organizationName: ProjectEnvironment.organizationName,
            settings: ProjectSettings.project(),
            targets: [featureTarget, testsTarget],
            schemes: [
                .scheme(
                    name: featureName,
                    shared: true,
                    buildAction: .buildAction(targets: [.target(featureName)]),
                    testAction: .targets([.testableTarget(target: .target("FeatureTests"))])
                )
            ]
        )
    }

    /// App 타겟 생성. 이름·식별자·표시 이름·Info.plist·scheme 은 `AppDescription` 에서 온다.
    /// `includesTests` 면 `<targetName>Tests` 를 만들어 모든 scheme 의 테스트 동작에 넣는다.
    /// `kitDependencies` 가 있으면 `Kit/**` 를 프레임워크 `<targetName>Kit` 으로 만든다.
    /// 앱과 테스트가 Kit 에 의존하고, 테스트는 앱을 띄우지 않는다.
    public static func app(
        _ description: AppDescription,
        dependencies: [TargetDependency],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements = ["Resources/**"],
        entitlements: Entitlements? = nil,
        includesTests: Bool = false,
        testsDependencies: [TargetDependency] = [],
        kitDependencies: [TargetDependency]? = nil
    ) -> Project {
        let kitName = kitDependencies.map { _ in "\(description.targetName)Kit" }
        let kitTarget = kitDependencies.map { kitDependencies in
            Target.target(
                name: "\(description.targetName)Kit",
                destinations: ProjectEnvironment.destinations,
                product: .framework,
                bundleId: "\(description.releaseBundleID).kit",
                deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
                sources: ["Kit/**"],
                dependencies: kitDependencies,
                settings: ProjectSettings.framework()
            )
        }
        let kitDependency: [TargetDependency] = kitName.map { [.target(name: $0)] } ?? []

        let target = Target.target(
            name: description.targetName,
            destinations: ProjectEnvironment.destinations,
            product: .app,
            bundleId: description.releaseBundleID,
            deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
            infoPlist: description.infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: kitDependency + dependencies,
            settings: ProjectSettings.app(description)
        )

        var targets = [target] + (kitTarget.map { [$0] } ?? [])
        var testsName: String?

        if includesTests {
            let name = "\(description.targetName)Tests"
            let testedDependency: [TargetDependency] = kitDependency.isEmpty
                ? [.target(name: description.targetName)]
                : kitDependency
            targets.append(
                Target.target(
                    name: name,
                    destinations: ProjectEnvironment.destinations,
                    product: .unitTests,
                    bundleId: "\(description.releaseBundleID).tests",
                    deploymentTargets: .iOS(ProjectEnvironment.deploymentTarget),
                    sources: ["Tests/**"],
                    dependencies: testedDependency + testsDependencies,
                    settings: ProjectSettings.unitTests()
                )
            )
            testsName = name
        }

        return Project(
            name: description.module.targetName,
            organizationName: ProjectEnvironment.organizationName,
            settings: ProjectSettings.project(),
            targets: targets,
            schemes: description.schemes.map { scheme in
                makeAppScheme(scheme, targetName: description.targetName, testsName: testsName)
            }
        )
    }

    private static func makeBuildScheme(name: String) -> Scheme {
        .scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: [.target(name)])
        )
    }

    private static func makeAppScheme(
        _ scheme: AppScheme,
        targetName: String,
        testsName: String?
    ) -> Scheme {
        .scheme(
            name: scheme.name,
            shared: true,
            buildAction: .buildAction(targets: [.target(targetName)]),
            testAction: testsName.map { name in
                .targets(
                    [.testableTarget(target: .target(name))],
                    configuration: scheme.runConfiguration
                )
            },
            runAction: .runAction(
                configuration: scheme.runConfiguration,
                executable: .target(targetName)
            ),
            archiveAction: .archiveAction(configuration: scheme.archiveConfiguration),
            profileAction: .profileAction(
                configuration: scheme.archiveConfiguration,
                executable: .target(targetName)
            ),
            analyzeAction: .analyzeAction(configuration: scheme.runConfiguration)
        )
    }
}

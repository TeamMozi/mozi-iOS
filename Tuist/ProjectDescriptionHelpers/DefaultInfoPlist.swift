import ProjectDescription

public enum DefaultInfoPlist {
    public static let app: InfoPlist = .extendingDefault(with: [
        "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
        "CFBundleShortVersionString": .string(ProjectEnvironment.appVersion),
        "CFBundleVersion": .string(ProjectEnvironment.appBuildNumber),

        "API_BASE_URL": "$(API_BASE_URL)",

        "UILaunchStoryboardName": "LaunchScreen",
        "LSRequiresIPhoneOS": true,
        "UIRequiresFullScreen": true,
        "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait",
        ],
        // iPad 전용 orientation 키를 비워 iPhone-only 정책을 명확히 한다.
        "UISupportedInterfaceOrientations~ipad": [],
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [:],
        ],

        // 딥링크용 커스텀 스킴: mozi://home
        "CFBundleURLTypes": [
            [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": "$(PRODUCT_BUNDLE_IDENTIFIER)",
                "CFBundleURLSchemes": ["mozi"],
            ]
        ],
    ])

    public static let framework: InfoPlist = .default
    public static let test: InfoPlist = .default
}

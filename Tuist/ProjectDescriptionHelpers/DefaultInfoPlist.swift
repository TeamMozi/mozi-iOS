import ProjectDescription

public enum DefaultInfoPlist {
    public static let app: InfoPlist = .extendingDefault(with: [
        "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
        "CFBundleShortVersionString": .string(ProjectEnvironment.appVersion),
        "CFBundleVersion": .string(ProjectEnvironment.appBuildNumber),

        "API_BASE_URL": "$(API_BASE_URL)",
        "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",

        "UILaunchStoryboardName": "LaunchScreen",
        "UIUserInterfaceStyle": "Dark",
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

        // 카카오톡 로그인 가능 여부 조회용 스킴
        "LSApplicationQueriesSchemes": [
            "kakaokompassauth",
            "kakaolink",
            "kakaoplus",
        ],

        // 딥링크용 커스텀 스킴: mozi://home
        // 카카오 로그인 콜백: kakao{NATIVE_APP_KEY}://oauth
        "CFBundleURLTypes": [
            [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": "$(PRODUCT_BUNDLE_IDENTIFIER)",
                "CFBundleURLSchemes": ["mozi"],
            ],
            [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": "kakao-$(PRODUCT_BUNDLE_IDENTIFIER)",
                "CFBundleURLSchemes": ["kakao$(KAKAO_NATIVE_APP_KEY)"],
            ],
        ],
    ])

    public static let framework: InfoPlist = .default
    public static let test: InfoPlist = .default
}

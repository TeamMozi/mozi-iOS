import ProjectDescription

/// Tuist 공통 환경 상수.
/// 빌드 타임 기준값. 런타임 값은 Config/Info.plist → AppInfo로 읽는다.
public enum ProjectEnvironment {
    public static let organizationName = "teamMozi"
    public static let bundlePrefix = "com.teamMozi"
    public static let productName = "Mozi"
    public static let displayName = "모지(mozi)"

    public static let appVersion = "1.0.0"
    /// 빌드 설정 CURRENT_PROJECT_VERSION 의 기본값. Debug·CI 빌드가 쓴다.
    public static let appBuildNumber = "1"

    public static let swiftVersion = "6"
    public static let deploymentTarget = "26.0"
    /// iPhone only. iPad / Mac / Vision 제외.
    public static let destinations: Destinations = [.iPhone]

    public static let debugConfigName: ConfigurationName = .debug
    public static let releaseConfigName: ConfigurationName = .release

    public enum AppBundle {
        public static let debug = "\(ProjectEnvironment.bundlePrefix).debug"
        public static let release = "\(ProjectEnvironment.bundlePrefix).app"
    }

    /// 데모 앱 「모지 데모」 값. 두 구성이 같은 값을 쓴다.
    public enum DemoApp {
        public static let targetName = "MoziDemo"
        public static let schemeName = "MoziDemo"
        public static let bundleID = "\(ProjectEnvironment.bundlePrefix).demo"
        public static let displayName = "모지 데모"
    }

    /// 업로드 때 fastlane 이 아카이브 인자로 넘기는 빌드 설정 이름. 데모 앱 Info.plist 만 읽는다.
    public enum UploadBuildSetting {
        /// 업로드 문구(해시 포함)를 UTF-8 → Base64 로 바꾼 값.
        public static let note = "MOZI_BUILD_NOTE"
        /// 커밋 해시 7자리.
        public static let commitHash = "MOZI_BUILD_HASH"
    }

    public static func moduleBundleId(_ suffix: String) -> String {
        "\(bundlePrefix).\(suffix)"
    }
}

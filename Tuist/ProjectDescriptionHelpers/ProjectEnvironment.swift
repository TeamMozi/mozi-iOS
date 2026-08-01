import ProjectDescription

/// Tuist 공통 환경 상수.
/// 빌드 타임 기준값. 런타임 값은 Config/Info.plist → AppInfo로 읽는다.
public enum ProjectEnvironment {
    public static let organizationName = "teamMozi"
    public static let bundlePrefix = "com.teamMozi"
    public static let productName = "Mozi"
    public static let displayName = "모지(mozi)"

    public static let appVersion = "1.0.0"
    public static let appBuildNumber = "1"

    public static let swiftVersion = "6"
    public static let deploymentTarget = "18.0"
    /// iPhone only. iPad / Mac / Vision 제외.
    public static let destinations: Destinations = [.iPhone]

    public static let debugConfigName: ConfigurationName = .debug
    public static let releaseConfigName: ConfigurationName = .release

    public enum AppBundle {
        public static let debug = "\(ProjectEnvironment.bundlePrefix).debug"
        public static let release = "\(ProjectEnvironment.bundlePrefix).app"
    }

    public static func moduleBundleId(_ suffix: String) -> String {
        "\(bundlePrefix).\(suffix)"
    }
}

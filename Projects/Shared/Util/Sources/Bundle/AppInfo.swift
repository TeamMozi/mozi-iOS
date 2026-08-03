import Foundation

public enum AppInfo {
    public static var bundleID: String {
        Bundle.main.bundleIdentifier
            ?? Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String
            ?? "unknown.bundle"
    }

    public static var displayName: String {
        if let value = nonEmptyString(fromInfoDictionaryKey: "CFBundleDisplayName") {
            return value
        }
        if let value = nonEmptyString(fromInfoDictionaryKey: "CFBundleName") {
            return value
        }
        return "모지(mozi)"
    }

    public static var productName: String {
        nonEmptyString(fromInfoDictionaryKey: "CFBundleName") ?? displayName
    }

    public static var version: String {
        string(.appVersion) ?? "0.0.0"
    }

    public static var buildNumber: String {
        string(.buildNumber) ?? "0"
    }

    public static var versionBuild: String {
        "\(version) (\(buildNumber))"
    }

    public static var isDebugBuild: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    public static var apiBaseURL: URL {
        let raw = requiredString(.apiBaseURL)
        guard let url = URL(string: raw) else {
            preconditionFailure("Invalid API_BASE_URL in Info.plist: \(raw)")
        }
        return url
    }

    public static func string(_ key: InfoPlistKey) -> String? {
        nonEmptyString(fromInfoDictionaryKey: key.rawValue)
    }

    public static func requiredString(_ key: InfoPlistKey) -> String {
        guard let value = string(key) else {
            preconditionFailure("Missing Info.plist value for key: \(key.rawValue)")
        }
        return value
    }

    private static func nonEmptyString(fromInfoDictionaryKey key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

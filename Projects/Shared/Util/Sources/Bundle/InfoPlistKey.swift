import Foundation

public enum InfoPlistKey: String, Sendable {
    case apiBaseURL = "API_BASE_URL"
    case kakaoNativeAppKey = "KAKAO_NATIVE_APP_KEY"
    case appVersion = "CFBundleShortVersionString"
    case buildNumber = "CFBundleVersion"
}

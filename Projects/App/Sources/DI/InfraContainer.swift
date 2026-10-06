import CoreNetwork
import CoreSocialAuth
import CoreStorage
import Foundation

/// App 인프라 컨테이너. 설정과 Core factory 가 만든 객체를 보유한다.
struct InfraContainer: Sendable {
    let appConfig: AppConfiguration

    let networkConfig: NetworkConfiguration

    let socialAuthConfig: SocialAuthConfiguration
    let socialAuthServices: SocialAuthServices

    let userDefaults: any UserDefaultsStorage
    let keychain: any KeychainStorage
}

extension InfraContainer {
    @MainActor
    static func make() -> InfraContainer {
        let appConfig = AppConfiguration.make()
        let kakaoAppKey = requireKakaoNativeAppKeyIfNeeded(appConfig.kakaoNativeAppKey)

        let networkConfig = NetworkConfiguration(baseURL: appConfig.baseURL)

        let socialAuthConfig = SocialAuthConfiguration(kakaoAppKey: kakaoAppKey)
        let socialAuthServices = SocialAuthFactory.make(config: socialAuthConfig)

        // 키체인 service 는 Bundle ID 다. 바꾸면 저장된 로그인 세션을 못 읽는다.
        let storageConfig = StorageConfiguration(keychainService: appConfig.bundleID)
        let userDefaults = StorageFactory.makeUserDefaults(config: storageConfig)
        let keychain = StorageFactory.makeKeychain(config: storageConfig)

        return InfraContainer(
            appConfig: appConfig,
            networkConfig: networkConfig,
            socialAuthConfig: socialAuthConfig,
            socialAuthServices: socialAuthServices,
            userDefaults: userDefaults,
            keychain: keychain
        )
    }

    /// Debug 에서는 카카오 키 누락을 부트 시점에 즉시 실패시킨다.
    private static func requireKakaoNativeAppKeyIfNeeded(_ key: String?) -> String? {
        #if DEBUG
        guard let key, key.isEmpty == false else {
            preconditionFailure(
                """
                Missing KAKAO_NATIVE_APP_KEY.
                Copy Config/Example.xcconfig to Config/Debug.xcconfig and set the native app key for this scheme.
                """
            )
        }
        return key
        #else
        return key
        #endif
    }
}

import Foundation

/// CoreNetwork 의 유일한 생성 창구. 구현 타입은 모듈 밖에 드러내지 않는다.
public enum NetworkFactory {
    public static func makePlain(config: NetworkConfiguration) -> any NetworkClient {
        DefaultNetworkClient.plain(configuration: config)
    }

    public static func makeAuthed(
        config: NetworkConfiguration,
        tokenProvider: any TokenProviding,
        tokenRefresher: any TokenRefreshing
    ) -> any NetworkClient {
        DefaultNetworkClient.authed(
            configuration: config,
            tokenProvider: tokenProvider,
            tokenRefresher: tokenRefresher
        )
    }

    public static func makeUploader() -> any Uploading {
        DefaultUploader()
    }
}

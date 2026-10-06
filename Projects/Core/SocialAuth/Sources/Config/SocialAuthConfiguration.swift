import Foundation

public struct SocialAuthConfiguration: Sendable {
    public let kakaoAppKey: String?

    public init(kakaoAppKey: String?) {
        self.kakaoAppKey = kakaoAppKey
    }
}

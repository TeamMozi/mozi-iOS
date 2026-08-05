import Foundation

public struct SocialAuthServices: Sendable {
    public let kakao: any SocialAuthService
    public let apple: any SocialAuthService

    public init(kakao: any SocialAuthService, apple: any SocialAuthService) {
        self.kakao = kakao
        self.apple = apple
    }
}

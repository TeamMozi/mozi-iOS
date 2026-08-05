import Domain
import Foundation

public struct OAuthServices: Sendable {
    public let kakao: any OAuthService
    public let apple: any OAuthService

    public init(kakao: any OAuthService, apple: any OAuthService) {
        self.kakao = kakao
        self.apple = apple
    }

    public func service(for provider: AuthProvider) -> any OAuthService {
        switch provider {
        case .kakao:
            return kakao
        case .apple:
            return apple
        }
    }
}

public enum OAuthServiceFactory {
    /// PR1 stub. 실제 SDK 연동은 후속 구현으로 교체한다.
    public static func makeStub() -> OAuthServices {
        OAuthServices(
            kakao: NotConfiguredOAuthService(provider: .kakao),
            apple: NotConfiguredOAuthService(provider: .apple)
        )
    }
}

struct NotConfiguredOAuthService: OAuthService {
    let provider: AuthProvider

    func login() async throws -> String {
        switch provider {
        case .kakao:
            throw AuthError.notConfigured(
                message: "Kakao login is not configured yet"
            )
        case .apple:
            throw AuthError.notConfigured(
                message: "Apple login is not configured yet"
            )
        }
    }
}

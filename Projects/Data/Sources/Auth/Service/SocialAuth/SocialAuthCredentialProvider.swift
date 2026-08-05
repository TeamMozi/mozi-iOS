import CoreSocialAuth
import Domain
import Foundation

enum SocialAuthCredentialProvider {
    static func credential(
        for provider: AuthProvider,
        services: SocialAuthServices
    ) async throws -> String {
        do {
            switch provider {
            case .kakao:
                return try await services.kakao.login()
            case .apple:
                return try await services.apple.login()
            }
        } catch let error as SocialAuthError {
            throw map(error)
        } catch {
            throw AuthError.loginFailed
        }
    }

    private static func map(_ error: SocialAuthError) -> AuthError {
        switch error {
        case .cancelled:
            return .cancelled
        case .failed:
            return .loginFailed
        case let .notConfigured(message):
            return .notConfigured(message: message)
        }
    }
}

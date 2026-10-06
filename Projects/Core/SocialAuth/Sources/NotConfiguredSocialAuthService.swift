import Foundation

struct NotConfiguredSocialAuthService: SocialAuthService {
    private let message: String

    init(message: String) {
        self.message = message
    }

    func login() async throws -> String {
        throw SocialAuthError.notConfigured(message: message)
    }
}

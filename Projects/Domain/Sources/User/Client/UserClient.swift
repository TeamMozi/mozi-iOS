import Foundation
import ThirdParty

@DependencyClient
public struct UserClient: Sendable {
    public var completeOnboarding: @Sendable (OnboardingDraft) async throws -> AuthSession
}

extension UserClient: TestDependencyKey {
    public static let testValue = UserClient()
}

public extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}

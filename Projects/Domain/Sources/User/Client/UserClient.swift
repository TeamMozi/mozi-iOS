import Foundation
import ThirdParty

/// 사용자 프로필을 다루는 Domain 포트.
@DependencyClient
public struct UserClient: Sendable {
    /// 프로필·사진·카테고리를 저장한다. 하나라도 실패하면 던진다.
    /// 성공하면 기기에 저장된 세션의 프로필 완료 값을 참으로 바꾼다.
    public var completeOnboarding: @Sendable (OnboardingDraft) async throws -> Void
}

extension UserClient: TestDependencyKey {
    public static let testValue = UserClient()
    public static let previewValue = UserClient(
        completeOnboarding: { _ in
            try await Task.sleep(for: .seconds(1))
        }
    )
}

public extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}

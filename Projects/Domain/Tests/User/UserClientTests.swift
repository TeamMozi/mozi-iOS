import Domain
import XCTest

final class UserClientTests: XCTestCase {
    func test_UserClient_testValue는_생성_가능() {
        // testValue 는 UserClient.swift 의 TestDependencyKey 확장이 선언한다.
        // @DependencyClient 는 미구현 클로저를 채운 init 을 제공한다.
        _ = UserClient.testValue
    }

    func test_UserClient_previewValue는_기다린_뒤_성공한다() async throws {
        let draft = OnboardingDraft(
            nickname: "수연",
            birthDate: Date(timeIntervalSince1970: 0),
            gender: .female,
            introduction: nil,
            profileImage: .keep,
            interestIDs: ["1"]
        )
        try await UserClient.previewValue.completeOnboarding(draft)
    }
}

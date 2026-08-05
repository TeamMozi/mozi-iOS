import Domain
import Feature
import ThirdParty
import XCTest

@MainActor
final class OnboardingPlaceholderFeatureTests: XCTestCase {
    func test_로그아웃_성공하면_delegate_loggedOut() async {
        let store = TestStore(
            initialState: OnboardingPlaceholderFeature.State()
        ) {
            OnboardingPlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {}
        }

        await store.send(.logoutTapped) {
            $0.isLoggingOut = true
            $0.errorMessage = nil
        }
        await store.receive(.logoutResponse(.success(OnboardingPlaceholderFeature.EquatableVoid()))) {
            $0.isLoggingOut = false
            $0.errorMessage = nil
        }
        await store.receive(.delegate(.loggedOut))
    }

    func test_로그아웃_로컬삭제_실패면_에러표시_후_유지() async {
        let store = TestStore(
            initialState: OnboardingPlaceholderFeature.State()
        ) {
            OnboardingPlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {
                throw AuthError.storage(message: "keychain")
            }
        }

        await store.send(.logoutTapped) {
            $0.isLoggingOut = true
            $0.errorMessage = nil
        }
        await store.receive(.logoutResponse(.failure(.storage(message: "keychain")))) {
            $0.isLoggingOut = false
            $0.errorMessage = "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요."
        }
    }
}

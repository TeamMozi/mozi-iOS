import Feature
import ThirdParty
import XCTest

@MainActor
final class OnboardingPlaceholderFeatureTests: XCTestCase {
    func test_끝내기를_누르면_delegate_finished() async {
        let store = TestStore(initialState: OnboardingPlaceholderFeature.State()) {
            OnboardingPlaceholderFeature()
        }

        await store.send(.finishTapped)
        await store.receive(.delegate(.finished))
    }
}

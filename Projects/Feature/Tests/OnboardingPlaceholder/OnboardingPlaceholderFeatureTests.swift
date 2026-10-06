import Feature
import ThirdParty
import XCTest

@MainActor
final class OnboardingPlaceholderFeatureTests: XCTestCase {
    func test_끝내기를_누르면_온보딩_끝을_위로_올린다() async {
        let store = TestStore(initialState: OnboardingPlaceholderFeature.State()) {
            OnboardingPlaceholderFeature()
        }

        await store.send(.finishTapped)
        await store.receive(.delegate(.finished))
    }
}

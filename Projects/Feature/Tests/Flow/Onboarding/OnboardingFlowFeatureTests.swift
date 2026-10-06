import Feature
import ThirdParty
import XCTest

@MainActor
final class OnboardingFlowFeatureTests: XCTestCase {
    func test_자리표시_화면에서_끝내기를_누르면_온보딩_끝을_위로_올린다() async {
        let store = TestStore(initialState: OnboardingFlowFeature.State()) {
            OnboardingFlowFeature()
        }

        await store.send(.onboarding(.finishTapped))
        await store.receive(.onboarding(.delegate(.finished)))
        await store.receive(.delegate(.finished))
    }

    func test_처음에는_쌓인_화면이_없다() {
        let path: StackState<OnboardingFlowFeature.Route.State> = OnboardingFlowFeature.State().path
        XCTAssertTrue(path.isEmpty)
    }
}

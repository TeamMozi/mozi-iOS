import Feature
import ThirdParty
import XCTest

@MainActor
final class NavigationSampleFeatureTests: XCTestCase {
    func test_다음을_누르면_다음_화면을_위로_요청한다() async {
        let store = TestStore(initialState: NavigationSampleFeature.State(number: 1)) {
            NavigationSampleFeature()
        }

        await store.send(.nextTapped)
        await store.receive(.delegate(.nextRequested))
    }

    func test_번호를_받으면_제목에_담긴다() {
        XCTAssertEqual(NavigationSampleFeature.State(number: 2).title, "견본 2")
    }
}

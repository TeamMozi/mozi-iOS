import Feature
import ThirdParty
import XCTest

@MainActor
final class NavigationSampleFeatureTests: XCTestCase {
    func test_다음을_누르면_delegate_nextRequested() async {
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

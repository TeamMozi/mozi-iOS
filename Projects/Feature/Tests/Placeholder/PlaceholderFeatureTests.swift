import Feature
import ThirdParty
import XCTest

@MainActor
final class PlaceholderFeatureTests: XCTestCase {
    func test_이름을_받으면_상태에_담긴다() async {
        let store = TestStore(
            initialState: PlaceholderFeature.State(title: "Shortform")
        ) {
            PlaceholderFeature()
        }

        XCTAssertEqual(store.state.title, "Shortform")
    }
}

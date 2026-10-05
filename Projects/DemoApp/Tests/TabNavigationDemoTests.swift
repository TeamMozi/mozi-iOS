import Feature
@testable import MoziDemoKit
import ThirdParty
import XCTest

@MainActor
final class TabNavigationDemoTests: XCTestCase {
    func test_첫_화면_상태는_쌓인_견본이_없다() {
        XCTAssertTrue(TabNavigationDemoState.root.shortformState.path.isEmpty)
    }

    func test_견본_상태는_고른_수만큼_1부터_번호를_매겨_쌓는다() {
        XCTAssertEqual(
            Array(TabNavigationDemoState.oneSample.shortformState.path),
            [.sample(NavigationSampleFeature.State(number: 1))]
        )
        XCTAssertEqual(
            Array(TabNavigationDemoState.twoSamples.shortformState.path),
            [
                .sample(NavigationSampleFeature.State(number: 1)),
                .sample(NavigationSampleFeature.State(number: 2)),
            ]
        )
    }
}

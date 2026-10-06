import Feature
import ThirdParty
import XCTest

@MainActor
final class TabFlowStackTests: XCTestCase {
    func test_검색_탭은_StackState_로_쌓고_처음에는_비어_있다() {
        let path: StackState<SearchFlowFeature.Route.State> = SearchFlowFeature.State().path
        XCTAssertTrue(path.isEmpty)
    }

    func test_채팅_탭은_StackState_로_쌓고_처음에는_비어_있다() {
        let path: StackState<ChatFlowFeature.Route.State> = ChatFlowFeature.State().path
        XCTAssertTrue(path.isEmpty)
    }

    func test_만들기_탭은_StackState_로_쌓고_처음에는_비어_있다() {
        let path: StackState<CreateFlowFeature.Route.State> = CreateFlowFeature.State().path
        XCTAssertTrue(path.isEmpty)
    }
}

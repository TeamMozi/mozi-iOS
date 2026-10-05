import Feature
import ThirdParty
import XCTest

@MainActor
final class ShortformFlowFeatureTests: XCTestCase {
    func test_견본에서_다음을_누르면_둘째가_쌓이고_뒤로_가기로_하나씩_빠진다() async throws {
        let store = TestStore(
            initialState: ShortformFlowFeature.State(
                path: StackState([.sample(NavigationSampleFeature.State(number: 1))])
            )
        ) {
            ShortformFlowFeature()
        }
        let firstID = try XCTUnwrap(store.state.path.ids.first)

        await store.send(.path(.element(id: firstID, action: .sample(.nextTapped))))
        // receive 는 Reducer 가 id 를 쓴 뒤에 생성기를 복사하므로 append 로는 id 가 어긋난다. TestStore 는 id 를 0 부터 차례로 매긴다
        await store.receive(.path(.element(id: firstID, action: .sample(.delegate(.nextRequested))))) {
            $0.path[id: 1] = .sample(NavigationSampleFeature.State(number: 2))
        }
        XCTAssertEqual(store.state.path.count, 2)

        let secondID = try XCTUnwrap(store.state.path.ids.last)
        await store.send(.path(.popFrom(id: secondID))) {
            $0.path.pop(from: secondID)
        }
        await store.send(.path(.popFrom(id: firstID))) {
            $0.path.pop(from: firstID)
        }
        XCTAssertTrue(store.state.path.isEmpty)
    }

    func test_처음에는_쌓인_화면이_없다() {
        let path: StackState<ShortformFlowFeature.Route.State> = ShortformFlowFeature.State().path
        XCTAssertTrue(path.isEmpty)
    }
}

import Feature
import ThirdParty
import XCTest

@MainActor
final class MyPageFlowFeatureTests: XCTestCase {
    func test_마이페이지_로그아웃은_위로_올린다() async {
        let store = TestStore(initialState: MyPageFlowFeature.State()) {
            MyPageFlowFeature()
        }

        await store.send(.myPage(.delegate(.loggedOut)))
        await store.receive(.delegate(.loggedOut))
    }

    func test_처음에는_쌓인_화면이_없다() {
        let path: StackState<MyPageFlowFeature.Route.State> = MyPageFlowFeature.State().path
        XCTAssertTrue(path.isEmpty)
    }
}

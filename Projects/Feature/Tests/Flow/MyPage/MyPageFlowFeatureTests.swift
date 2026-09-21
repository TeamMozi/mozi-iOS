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

    func test_경로가_비면_그대로_유지한다() async {
        let store = TestStore(initialState: MyPageFlowFeature.State()) {
            MyPageFlowFeature()
        }

        await store.send(.pathChanged([]))
    }
}

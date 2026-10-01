import Domain
import Feature
@testable import MoziDemo
import ThirdParty
import XCTest

@MainActor
final class DemoLoginFeatureTests: XCTestCase {
    func test_기본_상태에서_로그인을_누르면_1초_불러온_뒤_원래_화면으로_돌아온다() async {
        let clock = TestClock()
        let store = TestStore(initialState: DemoLoginFeature.State(demoState: .idle)) {
            DemoLoginFeature()
        } withDependencies: {
            $0.authClient = LoginDemoAuthClient.make(for: .idle, clock: clock)
        }

        await store.send(.login(.kakaoLoginTapped)) {
            $0.login.isLoading = true
        }
        await clock.advance(by: .milliseconds(999))
        // 불러오는 중이라 아무 일도 없는 입력. 1초 전에 응답이 와 있으면 TestStore 가 처리 안 된 응답으로 깨뜨린다
        await store.send(.login(.kakaoLoginTapped))
        await clock.advance(by: .milliseconds(1))
        await store.receive(.login(.loginResponse(.failure(.cancelled)))) {
            $0.login.isLoading = false
        }
    }

    func test_불러오는_중_상태는_처음부터_잠겨_있고_버튼을_눌러도_그대로다() async {
        let store = TestStore(initialState: DemoLoginFeature.State(demoState: .loading)) {
            DemoLoginFeature()
        } withDependencies: {
            $0.authClient = LoginDemoAuthClient.make(for: .loading)
        }

        XCTAssertTrue(store.state.login.isLoading)
        XCTAssertNil(store.state.overlay.toastMessage)
        await store.send(.login(.appleLoginTapped))
    }

    func test_오류_안내_상태는_토스트가_처음부터_뜬다() {
        let state = DemoLoginFeature.State(demoState: .networkError)

        XCTAssertFalse(state.login.isLoading)
        XCTAssertEqual(state.overlay.toastMessage, "네트워크 연결을 확인해 주세요")
    }

    func test_오류_안내_상태에서_로그인을_누르면_같은_토스트가_다시_뜬다() async {
        let store = TestStore(initialState: DemoLoginFeature.State(demoState: .networkError)) {
            DemoLoginFeature()
        } withDependencies: {
            $0.authClient = LoginDemoAuthClient.make(for: .networkError)
        }

        await store.send(.overlay(.dismissToast)) {
            $0.overlay.toastMessage = nil
        }
        await store.send(.login(.kakaoLoginTapped)) {
            $0.login.isLoading = true
        }
        await store.receive(.login(.loginResponse(.failure(.network)))) {
            $0.login.isLoading = false
        }
        await store.receive(.login(.delegate(.presentToast(LoginDemoState.networkErrorMessage))))
        await store.receive(.overlay(.showToast(LoginDemoState.networkErrorMessage))) {
            $0.overlay.toastMessage = LoginDemoState.networkErrorMessage
        }
    }
}

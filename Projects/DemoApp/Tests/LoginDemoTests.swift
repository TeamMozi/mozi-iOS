import Domain
import Feature
@testable import MoziDemoKit
import ThirdParty
import XCTest

@MainActor
final class LoginDemoTests: XCTestCase {
    func test_기본_상태에서_로그인을_누르면_1초_불러온_뒤_원래_화면으로_돌아온다() async {
        let clock = TestClock()
        let store = TestStore(initialState: LoginDemoState.idle.loginState) {
            LoginFeature()
        } withDependencies: {
            $0.authClient = LoginDemoAuthClient.make(for: .idle, clock: clock)
        }

        await store.send(.kakaoLoginTapped) {
            $0.screen = .loading
        }
        await clock.advance(by: .milliseconds(999))
        // 불러오는 중이라 아무 일도 없는 입력. 1초 전에 응답이 와 있으면 TestStore 가 처리 안 된 응답으로 깨뜨린다
        await store.send(.kakaoLoginTapped)
        await clock.advance(by: .milliseconds(1))
        await store.receive(.loginResponse(.failure(.cancelled))) {
            $0.screen = .idle
        }
    }

    func test_불러오는_중_상태는_처음부터_잠겨_있고_버튼을_눌러도_그대로다() async {
        let store = TestStore(initialState: LoginDemoState.loading.loginState) {
            LoginFeature()
        } withDependencies: {
            $0.authClient = LoginDemoAuthClient.make(for: .loading)
        }

        XCTAssertEqual(store.state.screen, .loading)
        XCTAssertTrue(store.state.isLoading)
        await store.send(.appleLoginTapped)
    }

    func test_오류_안내_상태는_얼럿이_처음부터_뜬다() {
        let state = LoginDemoState.networkError.loginState

        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.screen, .actionFailed(message: "네트워크 연결을 확인해 주세요"))
    }

    func test_오류_안내_상태에서_확인을_누르고_로그인을_누르면_같은_얼럿이_다시_뜬다() async {
        let store = TestStore(initialState: LoginDemoState.networkError.loginState) {
            LoginFeature()
        } withDependencies: {
            $0.authClient = LoginDemoAuthClient.make(for: .networkError)
        }

        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
        await store.send(.kakaoLoginTapped) {
            $0.screen = .loading
        }
        await store.receive(.loginResponse(.failure(.network))) {
            $0.screen = .actionFailed(message: LoginDemoState.networkErrorMessage)
        }
    }
}

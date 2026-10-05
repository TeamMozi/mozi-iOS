import Domain
import Feature
import ThirdParty
import XCTest

@MainActor
final class LoginFeatureTests: XCTestCase {
    func test_카카오_로그인_성공하면_delegate_loggedIn() async {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: false,
            profileCompleted: true,
            userID: "u1"
        )
        let store = TestStore(
            initialState: LoginFeature.State()
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { provider in
                XCTAssertEqual(provider, .kakao)
                return session
            }
        }

        await store.send(.kakaoLoginTapped) {
            $0.screen = .loading
        }
        await store.receive(.loginResponse(.success(session))) {
            $0.screen = .idle
        }
        await store.receive(.delegate(.loggedIn(session)))
    }

    func test_애플_로그인_성공하면_delegate_loggedIn() async {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: true,
            profileCompleted: false,
            userID: "u1"
        )
        let store = TestStore(
            initialState: LoginFeature.State()
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { provider in
                XCTAssertEqual(provider, .apple)
                return session
            }
        }

        await store.send(.appleLoginTapped) {
            $0.screen = .loading
        }
        await store.receive(.loginResponse(.success(session))) {
            $0.screen = .idle
        }
        await store.receive(.delegate(.loggedIn(session)))
    }

    func test_로그인_실패하면_screen이_actionFailed() async {
        await assertLoginFailure(.loginFailed, showsAlert: "로그인에 실패했어요")
    }

    func test_네트워크_실패하면_screen이_actionFailed() async {
        await assertLoginFailure(.network, showsAlert: "네트워크 연결을 확인해 주세요")
    }

    func test_인증_실패하면_screen이_actionFailed() async {
        await assertLoginFailure(.unauthorized, showsAlert: "로그인에 실패했어요")
    }

    func test_저장_실패하면_screen이_actionFailed() async {
        await assertLoginFailure(.storage(message: "keychain"), showsAlert: "로그인 정보를 저장하지 못했어요.")
    }

    func test_알수없는_실패하면_screen이_actionFailed() async {
        await assertLoginFailure(.unknown(message: "boom"), showsAlert: "알 수 없는 오류가 발생했어요.")
    }

    func test_설정누락이면_screen이_actionFailed() async {
        await assertLoginFailure(.notConfigured(message: "missing-key"), showsAlert: "로그인 설정이 완료되지 않았어요.")
    }

    func test_실패_얼럿을_닫으면_screen이_idle로_돌아온다() async {
        let store = TestStore(
            initialState: LoginFeature.State(screen: .actionFailed(message: "로그인에 실패했어요"))
        ) {
            LoginFeature()
        }

        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
    }

    func test_로그인_취소하면_피드백_없이_idle_복귀() async {
        let store = TestStore(
            initialState: LoginFeature.State()
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ in
                throw AuthError.cancelled
            }
        }

        await store.send(.kakaoLoginTapped) {
            $0.screen = .loading
        }
        await store.receive(.loginResponse(.failure(.cancelled))) {
            $0.screen = .idle
        }
    }

    func test_로딩중_중복탭은_무시() async {
        let store = TestStore(
            initialState: LoginFeature.State(screen: .loading)
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ in
                XCTFail("loading 중 login이 호출되면 안 됩니다.")
                throw AuthError.loginFailed
            }
        }

        await store.send(.kakaoLoginTapped)
    }

    func test_불러오는_중일_때만_isLoading이_참() {
        XCTAssertTrue(LoginFeature.State(screen: .loading).isLoading)
        XCTAssertFalse(LoginFeature.State().isLoading)
        XCTAssertFalse(LoginFeature.State(screen: .actionFailed(message: "로그인에 실패했어요")).isLoading)
    }

    private func assertLoginFailure(
        _ error: AuthError,
        showsAlert message: String
    ) async {
        let store = TestStore(
            initialState: LoginFeature.State()
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ in
                throw error
            }
        }

        await store.send(.kakaoLoginTapped) {
            $0.screen = .loading
        }
        await store.receive(.loginResponse(.failure(error))) {
            $0.screen = .actionFailed(message: message)
        }
    }
}

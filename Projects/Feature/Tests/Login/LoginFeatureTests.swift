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
            profileCompleted: true
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
            $0.isLoading = true
            $0.errorMessage = nil
        }
        await store.receive(.loginResponse(.success(session))) {
            $0.isLoading = false
            $0.errorMessage = nil
        }
        await store.receive(.delegate(.loggedIn(session)))
    }

    func test_애플_로그인_성공하면_delegate_loggedIn() async {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: true,
            profileCompleted: false
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
            $0.isLoading = true
            $0.errorMessage = nil
        }
        await store.receive(.loginResponse(.success(session))) {
            $0.isLoading = false
            $0.errorMessage = nil
        }
        await store.receive(.delegate(.loggedIn(session)))
    }

    func test_로그인_실패하면_에러메시지_표시() async {
        let store = TestStore(
            initialState: LoginFeature.State()
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ in
                throw AuthError.loginFailed
            }
        }

        await store.send(.appleLoginTapped) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        await store.receive(.loginResponse(.failure(.loginFailed))) {
            $0.isLoading = false
            $0.errorMessage = "로그인에 실패했어요"
        }
    }

    func test_네트워크_실패하면_연결확인_메시지_표시() async {
        let store = TestStore(
            initialState: LoginFeature.State()
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ in
                throw AuthError.network
            }
        }

        await store.send(.kakaoLoginTapped) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        await store.receive(.loginResponse(.failure(.network))) {
            $0.isLoading = false
            $0.errorMessage = "네트워크 연결을 확인해 주세요"
        }
    }

    func test_로그인_취소하면_에러메시지_없이_idle_복귀() async {
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
            $0.isLoading = true
            $0.errorMessage = nil
        }
        await store.receive(.loginResponse(.failure(.cancelled))) {
            $0.isLoading = false
            $0.errorMessage = nil
        }
    }

    func test_로딩중_중복탭은_무시() async {
        let store = TestStore(
            initialState: LoginFeature.State(isLoading: true)
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
}

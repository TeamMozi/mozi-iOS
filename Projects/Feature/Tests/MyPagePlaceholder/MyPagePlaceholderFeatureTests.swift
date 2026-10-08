import Domain
import Feature
import ThirdParty
import XCTest

@MainActor
final class MyPagePlaceholderFeatureTests: XCTestCase {
    func test_로그아웃_성공하면_delegate_loggedOut() async {
        let store = TestStore(
            initialState: MyPagePlaceholderFeature.State()
        ) {
            MyPagePlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {}
        }

        await store.send(.logoutTapped) {
            $0.isLoggingOut = true
            $0.errorMessage = nil
        }
        await store.receive(.logoutResponse(.success(MyPagePlaceholderFeature.EquatableVoid()))) {
            $0.isLoggingOut = false
            $0.errorMessage = nil
        }
        await store.receive(.delegate(.loggedOut))
    }

    func test_로그아웃_로컬삭제_실패면_에러표시_후_유지() async {
        let store = TestStore(
            initialState: MyPagePlaceholderFeature.State()
        ) {
            MyPagePlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = {
                throw AuthError.storage(message: "keychain")
            }
        }

        await store.send(.logoutTapped) {
            $0.isLoggingOut = true
            $0.errorMessage = nil
        }
        await store.receive(.logoutResponse(.failure(.storage(message: "keychain")))) {
            $0.isLoggingOut = false
            $0.errorMessage = "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요."
        }
    }

    func test_로그아웃_중_중복탭은_무시한다() async {
        let store = TestStore(
            initialState: MyPagePlaceholderFeature.State(isLoggingOut: true)
        ) {
            MyPagePlaceholderFeature()
        }

        await store.send(.logoutTapped)
    }

    func test_로그아웃_네트워크_실패는_네트워크_문구를_보인다() async {
        let store = TestStore(initialState: MyPagePlaceholderFeature.State()) {
            MyPagePlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = { throw AuthError.network }
        }

        await store.send(.logoutTapped) {
            $0.isLoggingOut = true
        }
        await store.receive(.logoutResponse(.failure(.network))) {
            $0.isLoggingOut = false
            $0.errorMessage = "네트워크 연결을 확인해 주세요"
        }
    }

    func test_로그아웃_그밖의_실패는_로그아웃_실패_문구를_보인다() async {
        let store = TestStore(initialState: MyPagePlaceholderFeature.State()) {
            MyPagePlaceholderFeature()
        } withDependencies: {
            $0.authClient.logout = { throw AuthError.unauthorized }
        }

        await store.send(.logoutTapped) {
            $0.isLoggingOut = true
        }
        await store.receive(.logoutResponse(.failure(.unauthorized))) {
            $0.isLoggingOut = false
            $0.errorMessage = "로그아웃에 실패했어요. 다시 시도해 주세요."
        }
    }
}

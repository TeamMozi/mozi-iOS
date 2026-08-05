import Domain
import Feature
import ThirdParty
import XCTest

@MainActor
final class AppCoordinatorFeatureTests: XCTestCase {
    func test_세션없으면_로그인으로_진입() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(phase: .bootstrapping)
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { nil }
        }

        await store.send(.onAppear)
        await store.receive(.bootstrapResponse(.success(nil))) {
            $0.phase = .login(LoginFeature.State())
        }
        await store.receive(.flushPendingDeepLink)
    }

    func test_프로필미완료_세션이면_온보딩으로_진입() async {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: true,
            profileCompleted: false
        )
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(phase: .bootstrapping)
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { session }
        }

        await store.send(.onAppear)
        await store.receive(.bootstrapResponse(.success(session))) {
            $0.phase = .onboarding(OnboardingPlaceholderFeature.State())
        }
        await store.receive(.flushPendingDeepLink)
    }

    func test_프로필완료_세션이면_메인으로_진입() async {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: false,
            profileCompleted: true
        )
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(phase: .bootstrapping)
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = { session }
        }

        await store.send(.onAppear)
        await store.receive(.bootstrapResponse(.success(session))) {
            $0.phase = .main(PlaceholderFeature.State())
        }
        await store.receive(.flushPendingDeepLink)
    }

    func test_로그인_성공_후_프로필완료면_메인으로_전환() async {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: false,
            profileCompleted: true
        )
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.login(.delegate(.loggedIn(session)))) {
            $0.phase = .main(PlaceholderFeature.State())
        }
        await store.receive(.flushPendingDeepLink)
    }

    func test_로그인_성공_후_프로필미완료면_온보딩으로_전환() async {
        let session = AuthSession(
            accessToken: "a",
            refreshToken: "r",
            isNewUser: true,
            profileCompleted: false
        )
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.login(.delegate(.loggedIn(session)))) {
            $0.phase = .onboarding(OnboardingPlaceholderFeature.State())
        }
        await store.receive(.flushPendingDeepLink)
    }

    func test_온보딩_로그아웃_delegate면_로그인으로_전환() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .onboarding(OnboardingPlaceholderFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.onboarding(.delegate(.loggedOut))) {
            $0.phase = .login(LoginFeature.State())
        }
    }

    func test_restore_실패하면_로그인으로_진입() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(phase: .bootstrapping)
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = {
                throw AuthError.storage(message: "keychain")
            }
        }

        await store.send(.onAppear)
        await store.receive(.bootstrapResponse(.failure(.storage(message: "keychain")))) {
            $0.phase = .login(LoginFeature.State())
        }
        await store.receive(.flushPendingDeepLink)
    }

    func test_로그인_중_딥링크는_pending으로_유지() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.routeDeepLink(.home)) {
            $0.pendingDeepLink = .home
        }
    }

    func test_온보딩_중_flush는_딥링크를_처리하지_않음() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .onboarding(OnboardingPlaceholderFeature.State()),
                pendingDeepLink: .home
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.flushPendingDeepLink)
    }

    func test_메인_진입_후_pending_딥링크를_flush() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .main(PlaceholderFeature.State()),
                pendingDeepLink: .home
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.flushPendingDeepLink) {
            $0.pendingDeepLink = nil
        }
        await store.receive(.routeDeepLink(.home))
    }
}

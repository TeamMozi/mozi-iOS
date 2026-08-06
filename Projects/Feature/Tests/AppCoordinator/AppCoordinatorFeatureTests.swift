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

        await store.send(.onAppear) {
            $0.isRestoringSession = true
        }
        await store.receive(.bootstrapResponse(.success(nil))) {
            $0.isRestoringSession = false
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

        await store.send(.onAppear) {
            $0.isRestoringSession = true
        }
        await store.receive(.bootstrapResponse(.success(session))) {
            $0.isRestoringSession = false
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

        await store.send(.onAppear) {
            $0.isRestoringSession = true
        }
        await store.receive(.bootstrapResponse(.success(session))) {
            $0.isRestoringSession = false
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

        await store.send(.onAppear) {
            $0.isRestoringSession = true
        }
        await store.receive(.bootstrapResponse(.failure(.storage(message: "keychain")))) {
            $0.isRestoringSession = false
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

    func test_부트스트랩_중복_onAppear는_restore를_한_번만_호출() async {
        let gate = RestoreGate()
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(phase: .bootstrapping)
        ) {
            AppCoordinatorFeature()
        } withDependencies: {
            $0.authClient.restoreSession = {
                await gate.markStartedAndWait()
                return nil
            }
        }

        await store.send(.onAppear) {
            $0.isRestoringSession = true
        }
        // restore 응답을 붙잡아 둔 상태에서 중복 onAppear 를 보낸다.
        await gate.waitUntilStarted()
        await store.send(.onAppear)
        await gate.release()

        await store.receive(.bootstrapResponse(.success(nil))) {
            $0.isRestoringSession = false
            $0.phase = .login(LoginFeature.State())
        }
        await store.receive(.flushPendingDeepLink)

        let count = await gate.startCount
        XCTAssertEqual(count, 1)
    }

    func test_로그인_toast_delegate면_overlay_toast_표시() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.login(.delegate(.presentToast("로그인에 실패했어요"))))
        await store.receive(.overlay(.showToast("로그인에 실패했어요"))) {
            $0.overlay.toastMessage = "로그인에 실패했어요"
        }
    }

    func test_로그인_alert_delegate면_overlay_alert_표시() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(
                phase: .login(LoginFeature.State())
            )
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.login(.delegate(.presentAlert("로그인 설정이 완료되지 않았어요."))))
        await store.receive(.overlay(.showAlert("로그인 설정이 완료되지 않았어요."))) {
            $0.overlay.alertMessage = "로그인 설정이 완료되지 않았어요."
        }
    }
}

private actor RestoreGate {
    private(set) var startCount = 0
    private var startedContinuation: CheckedContinuation<Void, Never>?
    private var releaseContinuation: CheckedContinuation<Void, Never>?
    private var isStarted = false
    private var isReleased = false

    func markStartedAndWait() async {
        startCount += 1
        if isStarted == false {
            isStarted = true
            startedContinuation?.resume()
            startedContinuation = nil
        }
        if isReleased {
            return
        }
        await withCheckedContinuation { continuation in
            releaseContinuation = continuation
        }
    }

    func waitUntilStarted() async {
        if isStarted {
            return
        }
        await withCheckedContinuation { continuation in
            startedContinuation = continuation
        }
    }

    func release() {
        isReleased = true
        releaseContinuation?.resume()
        releaseContinuation = nil
    }
}

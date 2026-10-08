import Domain
import Feature
import ThirdParty
import XCTest

@MainActor
final class RootFlowOnboardingTests: XCTestCase {
    func test_온보딩_끝이면_메인으로_넘기고_보관한_딥링크를_처리한다() async {
        let store = TestStore(
            initialState: RootFlowFeature.State(
                phase: .onboarding(OnboardingFlowFeature.State()),
                pendingDeepLink: .home
            )
        ) {
            RootFlowFeature()
        }

        await store.send(.onboarding(.delegate(.finished))) {
            $0.phase = .main(MainTabFeature.State())
        }
        await store.receive(.flushPendingDeepLink) {
            $0.pendingDeepLink = nil
        }
        await store.receive(.routeDeepLink(.home))
        await store.receive(.main(.openDeepLink(.home)))
    }

    func test_온보딩_끝이면_보관한_딥링크가_없어도_메인으로_넘긴다() async {
        let store = TestStore(
            initialState: RootFlowFeature.State(
                phase: .onboarding(OnboardingFlowFeature.State())
            )
        ) {
            RootFlowFeature()
        }

        await store.send(.onboarding(.delegate(.finished))) {
            $0.phase = .main(MainTabFeature.State())
        }
        await store.receive(.flushPendingDeepLink)
    }

    func test_온보딩에서_로그아웃하면_로그인으로_가고_보관한_딥링크는_남는다() async {
        let store = TestStore(
            initialState: RootFlowFeature.State(
                phase: .onboarding(OnboardingFlowFeature.State()),
                pendingDeepLink: .home
            )
        ) {
            RootFlowFeature()
        }

        await store.send(.onboarding(.delegate(.loggedOut))) {
            $0.phase = .login(LoginFeature.State())
        }
        XCTAssertEqual(store.state.pendingDeepLink, .home)
    }
}

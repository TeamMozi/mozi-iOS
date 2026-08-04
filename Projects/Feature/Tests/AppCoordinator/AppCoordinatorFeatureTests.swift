import Feature
import ThirdParty
import XCTest

@MainActor
final class AppCoordinatorFeatureTests: XCTestCase {
    func test_부트스트랩이_끝나면_메인_플레이스홀더로_진입() async {
        let store = TestStore(
            initialState: AppCoordinatorFeature.State(phase: .bootstrapping)
        ) {
            AppCoordinatorFeature()
        }

        await store.send(.onAppear) {
            $0.phase = .main(PlaceholderFeature.State())
        }
        await store.receive(\.flushPendingDeepLink)
    }
}

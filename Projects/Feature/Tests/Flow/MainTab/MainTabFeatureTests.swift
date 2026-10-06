@testable import Feature
import ThirdParty
import XCTest

@MainActor
final class MainTabFeatureTests: XCTestCase {
    func test_첫_탭은_숏폼이다() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        XCTAssertEqual(store.state.selectedTab, .shortform)
    }

    func test_탭을_고르면_선택_상태가_바뀐다() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.tabSelected(.chat)) {
            $0.selectedTab = .chat
        }
    }

    func test_마이_탭_로그아웃은_위로_올린다() async {
        let store = TestStore(initialState: MainTabFeature.State()) {
            MainTabFeature()
        }

        await store.send(.myPage(.delegate(.loggedOut)))
        await store.receive(.delegate(.loggedOut))
    }

    func test_홈_딥링크는_숏폼_탭을_고르고_숏폼의_쌓인_화면을_비운다() async {
        let store = TestStore(
            initialState: MainTabFeature.State(
                selectedTab: .chat,
                shortform: ShortformFlowFeature.State(
                    path: StackState([
                        .sample(NavigationSampleFeature.State(number: 1)),
                        .sample(NavigationSampleFeature.State(number: 2)),
                    ])
                )
            )
        ) {
            MainTabFeature()
        }

        await store.send(.openDeepLink(.home)) {
            $0.selectedTab = .shortform
            $0.shortform.path.removeAll()
        }
    }

    func test_탭이_다섯이다() {
        XCTAssertEqual(MainTabFeature.Tab.allCases.count, 5)
    }

    func test_탭마다_디자인_시스템_탭바_아이콘을_고른다() {
        XCTAssertEqual(
            MainTabFeature.Tab.allCases.map(\.tabBarIcon),
            [.playStack, .search, .chat, .person, .plus]
        )
    }
}

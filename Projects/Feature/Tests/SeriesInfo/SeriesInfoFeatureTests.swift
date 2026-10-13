@testable import Feature
import ThirdParty
import XCTest

@MainActor
final class SeriesInfoFeatureTests: XCTestCase {
    func test_시리즈명이_비어_있으면_다음을_눌러도_아무_일도_없다() async {
        let store = TestStore(initialState: SeriesInfoFeature.State(title: "   ")) {
            SeriesInfoFeature()
        }

        await store.send(.nextTapped)
    }

    func test_시리즈명과_소개를_넣고_다음을_누르면_둘을_올린다() async {
        let store = TestStore(initialState: SeriesInfoFeature.State()) {
            SeriesInfoFeature()
        }

        await store.send(.binding(.set(\.title, " 케이크 시리즈 "))) {
            $0.title = " 케이크 시리즈 "
        }
        await store.send(.binding(.set(\.intro, "매달 케이크 한 판"))) {
            $0.intro = "매달 케이크 한 판"
        }
        await store.send(.nextTapped)
        await store.receive(.delegate(.nextRequested(title: "케이크 시리즈", intro: "매달 케이크 한 판")))
    }

    func test_소개가_비어_있으면_소개_없이_올린다() async {
        let store = TestStore(initialState: SeriesInfoFeature.State(title: "케이크 시리즈")) {
            SeriesInfoFeature()
        }

        await store.send(.nextTapped)
        await store.receive(.delegate(.nextRequested(title: "케이크 시리즈", intro: nil)))
    }

    func test_요청_중이면_다음을_눌러도_올리지_않는다() async {
        let store = TestStore(initialState: SeriesInfoFeature.State(title: "케이크 시리즈", isSubmitting: true)) {
            SeriesInfoFeature()
        }

        await store.send(.nextTapped)
    }

    func test_실패_창을_닫으면_화면_상태를_되돌린다() async {
        let store = TestStore(
            initialState: SeriesInfoFeature.State(title: "케이크 시리즈", screen: .actionFailed(message: "실패"))
        ) {
            SeriesInfoFeature()
        }

        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
    }
}

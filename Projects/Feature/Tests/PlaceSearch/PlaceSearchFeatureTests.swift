import Domain
@testable import Feature
import ThirdParty
import XCTest

@MainActor
final class PlaceSearchFeatureTests: XCTestCase {
    private let hidden = Place(name: "히든스테이", address: "서울 구로구 구로동로26길 62", latitude: 37.49, longitude: 126.88)
    private let party = Place(name: "홍대파티룸 히든스테이", address: "서울 마포구 와우산로3길 48", latitude: 37.55, longitude: 126.92)

    func test_검색_키를_누르면_검색어로_한_번_검색한다() async {
        let queries = LockIsolated<[String]>([])
        let results = [hidden, party]
        let store = TestStore(initialState: PlaceSearchFeature.State(query: " 히든스테이 ")) {
            PlaceSearchFeature()
        } withDependencies: {
            $0.placeClient.search = { query in
                queries.withValue { $0.append(query) }
                return results
            }
        }

        await store.send(.searchSubmitted) {
            $0.isSearching = true
        }
        await store.receive(.searchResponse(.success(results))) {
            $0.isSearching = false
            $0.hasSearched = true
            $0.results = results
        }
        XCTAssertEqual(queries.value, ["히든스테이"])
    }

    func test_검색어가_공백뿐이면_검색하지_않는다() async {
        let store = TestStore(initialState: PlaceSearchFeature.State(query: "   ")) {
            PlaceSearchFeature()
        }

        await store.send(.searchSubmitted)
    }

    func test_검색_결과가_0건이면_빈_목록과_검색함_상태가_된다() async {
        var state = PlaceSearchFeature.State(query: "없는곳")
        state.results = [hidden]
        state.hasSearched = true
        state.selectedIndex = 0
        let store = TestStore(initialState: state) {
            PlaceSearchFeature()
        } withDependencies: {
            $0.placeClient.search = { _ in [] }
        }

        await store.send(.searchSubmitted) {
            $0.isSearching = true
            $0.selectedIndex = nil
        }
        await store.receive(.searchResponse(.success([]))) {
            $0.isSearching = false
            $0.results = []
        }
        XCTAssertTrue(store.state.hasSearched)
        XCTAssertNil(store.state.selectedPlace)
    }

    func test_장소를_고르지_않으면_체크가_꺼져_있고_눌러도_아무_일도_없다() async {
        var state = PlaceSearchFeature.State(query: "히든스테이")
        state.results = [hidden, party]
        state.hasSearched = true
        let store = TestStore(initialState: state) {
            PlaceSearchFeature()
        }

        XCTAssertFalse(store.state.canConfirm)
        await store.send(.doneTapped)
    }

    func test_검색_전에는_체크가_꺼져_있다() {
        XCTAssertFalse(PlaceSearchFeature.State().canConfirm)
    }

    func test_장소를_고르면_체크가_켜지고_누르면_고른_장소를_올린다() async {
        var state = PlaceSearchFeature.State(query: "히든스테이")
        state.results = [hidden, party]
        state.hasSearched = true
        let store = TestStore(initialState: state) {
            PlaceSearchFeature()
        }

        await store.send(.placeTapped(1)) {
            $0.selectedIndex = 1
        }
        XCTAssertTrue(store.state.canConfirm)
        await store.send(.doneTapped)
        await store.receive(.delegate(.placeChosen(party)))
    }

    func test_다시_검색하면_고른_줄이_풀려_체크가_꺼진다() async {
        let party = party
        var state = PlaceSearchFeature.State(query: "히든스테이")
        state.results = [hidden, party]
        state.hasSearched = true
        state.selectedIndex = 0
        let store = TestStore(initialState: state) {
            PlaceSearchFeature()
        } withDependencies: {
            $0.placeClient.search = { _ in [party] }
        }

        await store.send(.searchSubmitted) {
            $0.isSearching = true
            $0.selectedIndex = nil
        }
        XCTAssertFalse(store.state.canConfirm)
        await store.receive(.searchResponse(.success([party]))) {
            $0.isSearching = false
            $0.results = [party]
        }
    }

    func test_검색이_실패하면_오류_창을_띄운다() async {
        let store = TestStore(initialState: PlaceSearchFeature.State(query: "히든스테이")) {
            PlaceSearchFeature()
        } withDependencies: {
            $0.placeClient.search = { _ in throw PlaceError.unknown(message: "서버") }
        }

        await store.send(.searchSubmitted) {
            $0.isSearching = true
        }
        await store.receive(.searchResponse(.failure(.unknown(message: "서버")))) {
            $0.isSearching = false
            $0.screen = .actionFailed(message: PlaceSearchFeature.defaultFailureMessage)
        }
        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
    }
}

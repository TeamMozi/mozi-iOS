@testable import Feature
import ThirdParty
import XCTest

final class FeatureLogReducerTests: XCTestCase {
    func test_액션을_case이름과_라벨붙은_페이로드로_나눈다() {
        enum SampleAction {
            case loginButtonTapped(provider: String)
            case onAppear
        }

        let parsed = FeatureLogActionParser.nameAndPayload(SampleAction.loginButtonTapped(provider: "apple"))
        XCTAssertEqual(parsed.name, "loginButtonTapped")
        XCTAssertEqual(parsed.payload, "provider=apple")

        let appear = FeatureLogActionParser.nameAndPayload(SampleAction.onAppear)
        XCTAssertEqual(appear.name, "onAppear")
        XCTAssertNil(appear.payload)
    }

    func test_상태는_최상위_필드만_비교한다() {
        struct SampleState: Equatable {
            var isLoading = false
            var count = 0
            var child = "a"
        }

        let old = SampleState(isLoading: false, count: 0, child: "a")
        let new = SampleState(isLoading: true, count: 0, child: "b")
        let changes = FeatureLogStateDiff.changedFields(from: old, to: new)

        XCTAssertEqual(changes.map(\.field), ["isLoading", "child"])
        XCTAssertEqual(changes.first { $0.field == "isLoading" }?.from, "false")
        XCTAssertEqual(changes.first { $0.field == "isLoading" }?.to, "true")
    }

    func test_밑줄_저장라벨은_떼고_달러_관리라벨은_버린다() {
        XCTAssertEqual(FeatureLogStateDiff.normalizedFieldLabel("isLoading"), "isLoading")
        XCTAssertEqual(FeatureLogStateDiff.normalizedFieldLabel("_isLoading"), "isLoading")
        XCTAssertEqual(FeatureLogStateDiff.normalizedFieldLabel("_phase"), "phase")
        XCTAssertNil(FeatureLogStateDiff.normalizedFieldLabel("_$observationRegistrar"))
        XCTAssertNil(FeatureLogStateDiff.normalizedFieldLabel("_$id"))
    }

    func test_옵저버블_저장라벨도_필드이름으로_비교한다() {
        // @ObservableState 는 멤버를 `_필드` 와 `_$...` 관리 필드로 저장한다
        struct ObservableLikeState: Equatable, CustomReflectable {
            var isLoading = false
            var phase = "bootstrapping"
            var errorMessage: String?
            var observationRegistrar = 0

            var customMirror: Mirror {
                Mirror(
                    self,
                    children: [
                        "_isLoading": isLoading,
                        "_phase": phase,
                        "_errorMessage": errorMessage as Any,
                        "_$observationRegistrar": observationRegistrar
                    ],
                    displayStyle: .struct
                )
            }
        }

        let old = ObservableLikeState(
            isLoading: false,
            phase: "bootstrapping",
            errorMessage: nil,
            observationRegistrar: 0
        )
        let new = ObservableLikeState(
            isLoading: true,
            phase: "main",
            errorMessage: "failed",
            observationRegistrar: 1
        )

        let changes = FeatureLogStateDiff.changedFields(from: old, to: new)

        XCTAssertEqual(changes.map(\.field), ["isLoading", "phase", "errorMessage"])
        XCTAssertEqual(changes.first { $0.field == "phase" }?.to, "main")
        XCTAssertEqual(changes.first { $0.field == "errorMessage" }?.from, "nil")
        XCTAssertEqual(changes.first { $0.field == "errorMessage" }?.to, "failed")
    }

    func test_phase_selectedTab_pendingDeepLink만_화면이동_종류가_있다() {
        XCTAssertEqual(
            FeatureLogStateDiff.navigationStyle(for: .init(field: "phase", from: "bootstrapping", to: "main")),
            .phase
        )
        XCTAssertEqual(
            FeatureLogStateDiff.navigationStyle(for: .init(field: "selectedTab", from: "chat", to: "shortform")),
            .tab
        )
        XCTAssertEqual(
            FeatureLogStateDiff.navigationStyle(for: .init(field: "pendingDeepLink", from: "nil", to: "home")),
            .deepLink
        )
        XCTAssertNil(
            FeatureLogStateDiff.navigationStyle(for: .init(field: "isLoading", from: "false", to: "true"))
        )
    }

    func test_스택_칸수가_하나_늘거나_줄면_그_화면_case이름을_남긴다() {
        XCTAssertEqual(
            FeatureLogStateDiff.stackChange(field: "path", from: ["sample"], to: ["sample", "sample"]),
            .init(field: "path", style: .push, detail: "sample")
        )
        XCTAssertEqual(
            FeatureLogStateDiff.stackChange(field: "path", from: ["sample", "sample"], to: ["sample"]),
            .init(field: "path", style: .pop, detail: "sample")
        )
    }

    func test_스택_칸수가_여럿_바뀌면_칸수를_남기고_같으면_남기지_않는다() {
        XCTAssertEqual(
            FeatureLogStateDiff.stackChange(field: "path", from: ["a", "b", "c"], to: []),
            .init(field: "path", style: .pop, detail: "3")
        )
        XCTAssertEqual(
            FeatureLogStateDiff.stackChange(field: "path", from: [], to: ["a", "b"]),
            .init(field: "path", style: .push, detail: "2")
        )
        XCTAssertNil(FeatureLogStateDiff.stackChange(field: "path", from: ["a"], to: ["b"]))
    }

    func test_screen_실패case나_errorMessage_nil에서_값이면_화면에_뜬_오류다() {
        XCTAssertTrue(
            FeatureLogStateDiff.becameUserVisible(from: [.init(field: "screen", from: "loading", to: "actionFailed")])
        )
        XCTAssertTrue(
            FeatureLogStateDiff.becameUserVisible(from: [.init(field: "screen", from: "loading", to: "loadFailed")])
        )
        XCTAssertTrue(
            FeatureLogStateDiff.becameUserVisible(from: [.init(field: "errorMessage", from: "nil", to: "network")])
        )
    }

    func test_screen_idle이나_errorMessage_값에서_값이면_화면에_뜬_오류가_아니다() {
        XCTAssertFalse(
            FeatureLogStateDiff.becameUserVisible(from: [.init(field: "screen", from: "loading", to: "idle")])
        )
        XCTAssertFalse(
            FeatureLogStateDiff.becameUserVisible(from: [.init(field: "errorMessage", from: "old", to: "new")])
        )
        XCTAssertFalse(
            FeatureLogStateDiff.becameUserVisible(from: [.init(field: "toast", from: "nil", to: "x")])
        )
    }

    func test_enum은_연관값_없이_case이름만_남긴다() {
        enum Phase {
            case bootstrapping
            case login(String)
            case main(nested: NestedState)
        }

        struct NestedState: Equatable {
            var isLoading = true
            var title = "home"
        }

        XCTAssertEqual(FeatureLog.summarizeValue(Phase.bootstrapping), "bootstrapping")

        let login = FeatureLog.summarizeValue(Phase.login("token"))
        XCTAssertEqual(login, "login")
        XCTAssertFalse(login.contains("token"))

        let main = FeatureLog.summarizeValue(Phase.main(nested: NestedState()))
        XCTAssertEqual(main, "main")
        XCTAssertFalse(main.contains("NestedState"))
    }

    // MARK: - 래퍼 회귀

    @MainActor
    func test_로그를_붙여도_상태결과는_같다() async {
        assertDebugBuild()

        let plain = TestStore(initialState: LogWrapperProbeFeature.State()) {
            LogWrapperProbeFeature()
        }
        let logged = TestStore(initialState: LogWrapperProbeFeature.State()) {
            LogWrapperProbeFeature().logged(as: LogWrapperProbeFeature.self, children: [])
        }

        for store in [plain, logged] {
            await store.send(.increment) { $0.count = 1 }
            await store.send(.noop)
            await store.send(.load) { $0.isLoading = true }
            await store.receive(.echoResponse("ok")) {
                $0.isLoading = false
                $0.lastEcho = "ok"
            }
            await store.send(.increment) { $0.count = 2 }
        }

        XCTAssertEqual(plain.state, logged.state)
    }

    @MainActor
    func test_로그를_붙여도_이펙트를_그대로_돌려준다() async {
        assertDebugBuild()

        let store = TestStore(initialState: LogWrapperProbeFeature.State()) {
            LogWrapperProbeFeature().logged(as: LogWrapperProbeFeature.self, children: [])
        }

        await store.send(.load) { $0.isLoading = true }
        await store.receive(.echoResponse("ok")) {
            $0.isLoading = false
            $0.lastEcho = "ok"
        }

        // `.none` 을 돌려주는 액션에 래퍼가 이펙트를 만들면 TestStore 가 실패시킨다
        await store.send(.increment) { $0.count = 1 }
        await store.send(.noop)
    }

    private func assertDebugBuild() {
        #if !DEBUG
        XCTFail("Feature 테스트는 Debug 빌드여야 FeatureLogReducer 의 로그 경로를 지난다")
        #endif
    }
}

private struct LogWrapperProbeFeature: Reducer {
    struct State: Equatable {
        var count = 0
        var isLoading = false
        var lastEcho: String?
    }

    enum Action: Equatable {
        case increment
        case load
        case echoResponse(String)
        case noop
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .increment:
            state.count += 1
            return .none

        case .load:
            state.isLoading = true
            return .run { send in
                await send(.echoResponse("ok"))
            }

        case let .echoResponse(value):
            state.isLoading = false
            state.lastEcho = value
            return .none

        case .noop:
            return .none
        }
    }
}

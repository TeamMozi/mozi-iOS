import Domain
@testable import Feature
import ThirdParty
import XCTest

@MainActor
final class FeatureLogEventsTests: XCTestCase {
    private let mainTabChildren: Set<String> = ["shortform", "search", "chat", "myPage", "create"]

    func test_숏폼에_견본이_하나_쌓이면_path_push_sample_한_줄이다() {
        let old = ShortformFlowFeature.State(
            path: StackState([.sample(NavigationSampleFeature.State(number: 1))])
        )
        var new = old
        new.path.append(.sample(NavigationSampleFeature.State(number: 2)))

        let events = FeatureLogEvents.afterReduce(
            action: ShortformFlowFeature.Action.placeholder(.onAppear),
            from: old,
            to: new,
            children: ["placeholder"]
        )

        XCTAssertEqual(events, [.stack(field: "path", style: .push, detail: "sample")])
    }

    func test_숏폼에서_견본이_하나_빠지면_path_pop_sample_한_줄이다() {
        let old = ShortformFlowFeature.State(
            path: StackState([
                .sample(NavigationSampleFeature.State(number: 1)),
                .sample(NavigationSampleFeature.State(number: 2)),
            ])
        )
        var new = old
        new.path.removeLast()

        let events = FeatureLogEvents.afterReduce(
            action: ShortformFlowFeature.Action.placeholder(.onAppear),
            from: old,
            to: new,
            children: ["placeholder"]
        )

        XCTAssertEqual(events, [.stack(field: "path", style: .pop, detail: "sample")])
    }

    func test_메인탭이_숏폼의_쌓인_화면_셋을_비우면_shortform_path_pop_3을_찍는다() {
        let old = MainTabFeature.State(
            selectedTab: .chat,
            shortform: ShortformFlowFeature.State(
                path: StackState([
                    .sample(NavigationSampleFeature.State(number: 1)),
                    .sample(NavigationSampleFeature.State(number: 2)),
                    .sample(NavigationSampleFeature.State(number: 3)),
                ])
            )
        )
        var new = old
        new.selectedTab = .shortform
        new.shortform.path.removeAll()

        let events = FeatureLogEvents.afterReduce(
            action: MainTabFeature.Action.openDeepLink(.home),
            from: old,
            to: new,
            children: mainTabChildren
        )

        XCTAssertEqual(
            events,
            [
                .navigation(field: "selectedTab", from: "chat", to: "shortform", style: .tab),
                .stack(field: "shortform.path", style: .pop, detail: "3"),
            ]
        )
    }

    func test_children에_없는_자식_상태_안의_path는_들여다보지_않는다() {
        let old = MainTabFeature.State(
            shortform: ShortformFlowFeature.State(
                path: StackState([.sample(NavigationSampleFeature.State(number: 1))])
            )
        )
        var new = old
        new.shortform.path.removeAll()

        let events = FeatureLogEvents.afterReduce(
            action: MainTabFeature.Action.openDeepLink(.home),
            from: old,
            to: new,
            children: []
        )

        XCTAssertEqual(events, [])
    }

    func test_children에_있는_자식_액션은_부모가_찍지_않는다() {
        XCTAssertEqual(
            FeatureLogEvents.beforeReduce(
                action: MainTabFeature.Action.myPage(.myPage(.logoutTapped)),
                children: mainTabChildren
            ),
            []
        )
        XCTAssertEqual(
            FeatureLogEvents.beforeReduce(
                action: MyPageFlowFeature.Action.myPage(.logoutTapped),
                children: ["myPage"]
            ),
            []
        )
    }

    func test_children에_없으면_같은_이름의_자식_액션도_사용자_액션으로_찍힌다() {
        XCTAssertEqual(
            FeatureLogEvents.beforeReduce(
                action: MainTabFeature.Action.myPage(.myPage(.logoutTapped)),
                children: []
            ),
            [.action(name: "myPage", payload: "myPage=logoutTapped")]
        )
    }

    func test_자기_액션은_case이름과_페이로드로_찍는다() {
        XCTAssertEqual(
            FeatureLogEvents.beforeReduce(action: MainTabFeature.Action.tabSelected(.chat), children: mainTabChildren),
            [.action(name: "tabSelected", payload: "chat")]
        )
        XCTAssertEqual(
            FeatureLogEvents.beforeReduce(action: MyPagePlaceholderFeature.Action.logoutTapped, children: []),
            [.action(name: "logoutTapped", payload: nil)]
        )
    }

    func test_delegate와_path_액션은_어느_층에서도_찍지_않는다() {
        XCTAssertEqual(
            FeatureLogEvents.beforeReduce(
                action: InterestSettingFeature.Action.delegate(.finished),
                children: []
            ),
            []
        )
        XCTAssertEqual(
            FeatureLogEvents.beforeReduce(
                action: ShortformFlowFeature.Action.path(.popFrom(id: 0)),
                children: ["placeholder"]
            ),
            []
        )
    }

    func test_screen이_actionFailed로_바뀐_실패는_userVisible_true다() {
        let events = FeatureLogEvents.afterReduce(
            action: LoginFeature.Action.loginResponse(.failure(.network)),
            from: LoginFeature.State(screen: .loading),
            to: LoginFeature.State(screen: .actionFailed(message: "네트워크 연결을 확인해 주세요")),
            children: []
        )

        XCTAssertEqual(
            events,
            [
                .state(field: "screen", from: "loading", to: "actionFailed"),
                .error(operation: "login", error: "network", userVisible: true),
            ]
        )
    }

    func test_screen이_loadFailed로_바뀐_실패는_userVisible_true다() {
        let events = FeatureLogEvents.afterReduce(
            action: LoginFeature.Action.loginResponse(.failure(.network)),
            from: LoginFeature.State(screen: .loading),
            to: LoginFeature.State(screen: .loadFailed(message: "불러오지 못했어요")),
            children: []
        )

        XCTAssertEqual(events.last, .error(operation: "login", error: "network", userVisible: true))
    }

    func test_errorMessage가_nil에서_값이_된_실패는_userVisible_true다() {
        let events = FeatureLogEvents.afterReduce(
            action: MyPagePlaceholderFeature.Action.logoutResponse(.failure(.storage(message: "keychain"))),
            from: MyPagePlaceholderFeature.State(isLoggingOut: true, errorMessage: nil),
            to: MyPagePlaceholderFeature.State(isLoggingOut: false, errorMessage: "로그아웃 정보를 지우지 못했어요."),
            children: []
        )

        XCTAssertEqual(
            events,
            [
                .state(field: "isLoggingOut", from: "true", to: "false"),
                .state(field: "errorMessage", from: "nil", to: "로그아웃 정보를 지우지 못했어요."),
                .error(operation: "logout", error: "storage", userVisible: true),
            ]
        )
    }

    func test_화면에_띄우지_않은_실패는_userVisible_false다() {
        let events = FeatureLogEvents.afterReduce(
            action: RootFlowFeature.Action.bootstrapResponse(.failure(.network)),
            from: RootFlowFeature.State(phase: .bootstrapping, isRestoringSession: true),
            to: RootFlowFeature.State(phase: .login(LoginFeature.State()), isRestoringSession: false),
            children: ["login", "onboarding", "main"]
        )

        XCTAssertEqual(
            events,
            [
                .navigation(field: "phase", from: "bootstrapping", to: "login", style: .phase),
                .state(field: "isRestoringSession", from: "true", to: "false"),
                .error(operation: "bootstrap", error: "network", userVisible: false),
            ]
        )
    }
}

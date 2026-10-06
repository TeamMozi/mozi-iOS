@testable import Feature
import ThirdParty
import XCTest

final class FeatureLogTests: XCTestCase {
    func test_타입이름이_Feature로_끝나면_장면이름은_접미를_뗀다() {
        XCTAssertEqual(FeatureLog.sceneName(from: "LoginFeature"), "Login")
        XCTAssertEqual(FeatureLog.sceneName(from: "RootFlowFeature"), "RootFlow")
        XCTAssertEqual(FeatureLog.sceneName(from: "MainTabFeature"), "MainTab")
        XCTAssertEqual(FeatureLog.sceneName(from: "Feature"), "Feature")
        XCTAssertEqual(FeatureLog.sceneName(from: "Root"), "Root")
        XCTAssertEqual(FeatureLog.sceneName(from: ShortformFlowFeature.self), "ShortformFlow")
    }

    func test_액션이름이_Response로_끝나면_작업이름은_접미를_뗀다() {
        XCTAssertEqual(FeatureLog.operationName(fromActionName: "loginResponse"), "login")
        XCTAssertEqual(FeatureLog.operationName(fromActionName: "logoutResponse"), "logout")
        XCTAssertEqual(FeatureLog.operationName(fromActionName: "bootstrapResponse"), "bootstrap")
        XCTAssertEqual(FeatureLog.operationName(fromActionName: "onAppear"), "onAppear")
    }

    func test_줄마다_Feature_장면_종류_순서로_찍힌다() {
        XCTAssertEqual(
            FeatureLog.actionMessage(scene: "Login", name: "kakaoLoginTapped"),
            "[Feature] [Login] 사용자 액션: kakaoLoginTapped"
        )
        XCTAssertEqual(
            FeatureLog.actionMessage(scene: "MainTab", name: "tabSelected", payload: "chat"),
            "[Feature] [MainTab] 사용자 액션: tabSelected(chat)"
        )
        XCTAssertEqual(
            FeatureLog.stateMessage(scene: "Login", field: "screen", from: "idle", to: "loading"),
            "[Feature] [Login] 상태 변경: screen(idle → loading)"
        )
        XCTAssertEqual(
            FeatureLog.navigationMessage(scene: "RootFlow", field: "phase", from: "bootstrapping", to: "main"),
            "[Feature] [RootFlow] 화면 이동: phase(bootstrapping → main)"
        )
        XCTAssertEqual(
            FeatureLog.errorMessage(scene: "Login", operation: "login", error: "network", userVisible: true),
            "[Feature] [Login] 오류: login(network, userVisible=true)"
        )
    }

    func test_스택_줄은_push_pop_뒤에_화면이름이나_칸수를_붙인다() {
        XCTAssertEqual(
            FeatureLog.stackMessage(scene: "ShortformFlow", field: "path", style: .push, detail: "sample"),
            "[Feature] [ShortformFlow] 화면 이동: path(push sample)"
        )
        XCTAssertEqual(
            FeatureLog.stackMessage(scene: "ShortformFlow", field: "path", style: .pop, detail: "sample"),
            "[Feature] [ShortformFlow] 화면 이동: path(pop sample)"
        )
        XCTAssertEqual(
            FeatureLog.stackMessage(scene: "MainTab", field: "shortform.path", style: .pop, detail: "3"),
            "[Feature] [MainTab] 화면 이동: shortform.path(pop 3)"
        )
    }

    func test_이벤트마다_같은_형식의_줄을_만든다() {
        XCTAssertEqual(
            FeatureLog.message(
                for: .stack(field: "path", style: .push, detail: "sample"),
                scene: "ShortformFlow"
            ),
            "[Feature] [ShortformFlow] 화면 이동: path(push sample)"
        )
        XCTAssertEqual(
            FeatureLog.message(
                for: .navigation(field: "selectedTab", from: "chat", to: "shortform", style: .tab),
                scene: "MainTab"
            ),
            "[Feature] [MainTab] 화면 이동: selectedTab(chat → shortform)"
        )
        XCTAssertEqual(
            FeatureLog.message(
                for: .error(operation: "logout", error: "storage", userVisible: false),
                scene: "MyPagePlaceholder"
            ),
            "[Feature] [MyPagePlaceholder] 오류: logout(storage, userVisible=false)"
        )
    }

    func test_구조체와_클래스는_타입이름만_남긴다() {
        struct ToastLikeState: Equatable {
            var message = "로그인에 실패했습니다."
            var icon: String?
        }

        final class SessionLikeBox {
            var email = "user@example.com"
        }

        let toast = FeatureLog.summarizeValue(ToastLikeState())
        XCTAssertEqual(toast, "ToastLikeState")
        XCTAssertFalse(toast.contains("로그인에 실패했습니다."))

        let presentToast: ToastLikeState? = ToastLikeState()
        XCTAssertEqual(FeatureLog.summarizeValue(presentToast), "ToastLikeState")
        XCTAssertEqual(FeatureLog.summarizeValue(ToastLikeState?.none), "nil")

        let boxed = FeatureLog.summarizeValue(SessionLikeBox())
        XCTAssertEqual(boxed, "SessionLikeBox")
        XCTAssertFalse(boxed.contains("user@example.com"))

        XCTAssertEqual(FeatureLog.summarizeValue("cafe"), "cafe")
        XCTAssertEqual(FeatureLog.summarizeValue(true), "true")
        XCTAssertEqual(FeatureLog.summarizeValue(false), "false")
        XCTAssertEqual(FeatureLog.summarizeValue(3), "3")
        XCTAssertEqual(FeatureLog.summarizeValue([1, 2, 3]), "3 items")
        XCTAssertEqual(FeatureLog.summarizeValue(["a": 1]), "1 items")
    }

    func test_120자를_넘는_문자열은_120자에서_자르고_말줄임표를_붙인다() {
        let long = String(repeating: "가", count: 200)

        let summarized = FeatureLog.summarizeValue(long)

        XCTAssertEqual(summarized, String(repeating: "가", count: 120) + "…")
    }

    func test_토큰은_REDACTED로_가린다() {
        let input = "accessToken=aaa refreshToken=bbb Authorization=Bearer ccc identityToken=ddd"
        let redacted = FeatureLog.redact(input)
        XCTAssertFalse(redacted.contains("aaa"))
        XCTAssertFalse(redacted.contains("bbb"))
        XCTAssertFalse(redacted.contains("ccc"))
        XCTAssertFalse(redacted.contains("ddd"))
        XCTAssertTrue(redacted.contains("[REDACTED]"))
    }
}

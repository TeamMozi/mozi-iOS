@testable import MoziDemoKit
import XCTest

final class DemoCatalogTests: XCTestCase {
    func test_흐름은_일곱이고_스펙_순서다() {
        XCTAssertEqual(
            DemoFlow.allCases.map(\.title),
            ["로그인", "온보딩", "숏폼", "검색", "만들기", "채팅", "마이"]
        )
    }

    func test_로그인과_숏폼만_열리고_나머지는_준비_중() {
        XCTAssertEqual(DemoFlow.allCases.filter(\.isReady), [.login, .shortform])
    }

    func test_로그인_흐름은_화면_하나() {
        XCTAssertEqual(DemoFlow.login.screens, [.login])
        XCTAssertEqual(DemoFlow.login.screenCountLabel, "화면 1")
        XCTAssertEqual(DemoFlow.login.screenCountTitle, "화면 1개")
    }

    func test_로그인_화면_줄은_상태_셋의_개수와_이름을_보인다() {
        XCTAssertEqual(DemoScreen.login.stateSummary, "상태 3개 · 기본, 불러오는 중, 오류 안내")
    }

    func test_데모_버튼에는_짧은_상태_이름을_적는다() {
        XCTAssertEqual(LoginDemoState.allCases.map(\.shortTitle), ["기본", "로딩", "오류"])
    }

    func test_숏폼_흐름은_탭_안_이동_화면_하나() {
        XCTAssertEqual(DemoFlow.shortform.screens, [.tabNavigation])
        XCTAssertEqual(DemoFlow.shortform.screenCountLabel, "화면 1")
        XCTAssertEqual(DemoFlow.shortform.screenCountTitle, "화면 1개")
    }

    func test_탭_안_이동_화면_줄은_상태_셋의_개수와_이름을_보인다() {
        XCTAssertEqual(DemoScreen.tabNavigation.title, "탭 안 이동")
        XCTAssertEqual(DemoScreen.tabNavigation.stateSummary, "상태 3개 · 첫 화면, 견본 1장, 견본 2장")
    }

    func test_탭_안_이동_데모_버튼에는_짧은_상태_이름을_적는다() {
        XCTAssertEqual(TabNavigationDemoState.allCases.map(\.shortTitle), ["처음", "1장", "2장"])
    }

    func test_탭_안_이동만_전체_화면으로_덮어_띄운다() {
        XCTAssertFalse(DemoScreen.login.presentsFullScreen)
        XCTAssertTrue(DemoScreen.tabNavigation.presentsFullScreen)
    }
}

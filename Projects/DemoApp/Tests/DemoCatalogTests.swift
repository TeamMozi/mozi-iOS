@testable import MoziDemoKit
import XCTest

final class DemoCatalogTests: XCTestCase {
    func test_흐름은_일곱이고_스펙_순서다() {
        XCTAssertEqual(
            DemoFlow.allCases.map(\.title),
            ["로그인", "온보딩", "숏폼", "검색", "만들기", "채팅", "마이"]
        )
    }

    func test_로그인과_온보딩과_숏폼만_열리고_나머지는_준비_중() {
        XCTAssertEqual(DemoFlow.allCases.filter(\.isReady), [.login, .onboarding, .shortform])
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

    func test_탭_안_이동과_온보딩_세_화면만_전체_화면으로_덮어_띄운다() {
        XCTAssertFalse(DemoScreen.login.presentsFullScreen)
        XCTAssertTrue(DemoScreen.tabNavigation.presentsFullScreen)
        XCTAssertTrue(DemoScreen.profileSetting.presentsFullScreen)
        XCTAssertTrue(DemoScreen.interestSetting.presentsFullScreen)
        XCTAssertTrue(DemoScreen.onboardingFlow.presentsFullScreen)
    }

    func test_온보딩_흐름은_프로필_카테고리_흐름_전체_세_화면() {
        XCTAssertEqual(DemoFlow.onboarding.screens, [.profileSetting, .interestSetting, .onboardingFlow])
        XCTAssertEqual(DemoFlow.onboarding.screenCountLabel, "화면 3")
        XCTAssertEqual(
            DemoFlow.onboarding.screens.map(\.title),
            ["프로필 설정", "카테고리 설정", "온보딩 흐름 전체"]
        )
    }

    func test_온보딩_화면_줄은_상태의_개수와_이름을_보인다() {
        XCTAssertEqual(DemoScreen.profileSetting.stateSummary, "상태 3개 · 빈 화면, 다 채운 화면, 로그아웃 실패")
        XCTAssertEqual(
            DemoScreen.interestSetting.stateSummary,
            "상태 6개 · 받는 중, 기본, 고른 상태, 저장 중, 받기 실패, 저장 실패"
        )
        XCTAssertEqual(DemoScreen.onboardingFlow.stateSummary, "상태 1개 · 처음부터")
    }

    func test_온보딩_데모_버튼에는_짧은_상태_이름을_적는다() {
        XCTAssertEqual(ProfileSettingDemoState.allCases.map(\.shortTitle), ["빈", "채움", "실패"])
        XCTAssertEqual(
            InterestSettingDemoState.allCases.map(\.shortTitle),
            ["받는 중", "기본", "고름", "저장 중", "받기 실패", "저장 실패"]
        )
        XCTAssertEqual(OnboardingFlowDemoState.allCases.map(\.shortTitle), ["처음"])
    }
}

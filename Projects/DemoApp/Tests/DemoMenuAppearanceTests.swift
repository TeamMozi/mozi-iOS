@testable import MoziDemoKit
import UIKit
import XCTest

final class DemoMenuAppearanceTests: XCTestCase {
    func test_화면_모드_칸은_시스템_다크_라이트_순서로_고른다() {
        XCTAssertEqual(DemoMenuAppearance.title, "화면 모드")
        XCTAssertEqual(DemoMenuAppearance.options.map(\.title), ["시스템", "다크", "라이트"])
    }

    func test_처음엔_시스템이고_기기_모드를_덮어쓰지_않는다() {
        XCTAssertEqual(DemoMenuAppearance.initial, .system)
        XCTAssertNil(DemoMenuAppearance.initial.colorScheme)
    }

    func test_다크와_라이트는_그_모드로_덮어쓴다() {
        XCTAssertEqual(DemoMenuAppearance.options.map(\.colorScheme), [nil, .dark, .light])
    }

    func test_앱_창에는_시스템은_덮어쓰지_않고_다크와_라이트는_그_모드로_건다() {
        XCTAssertEqual(
            DemoMenuAppearance.options.map(DemoMenuAppearance.interfaceStyle(for:)),
            [.unspecified, .dark, .light]
        )
    }

    func test_로그인_데모만_화면_모드를_고르지_않는다() {
        XCTAssertFalse(DemoScreen.login.selectsAppearance)
        let others: [DemoScreen] = [
            .profileSetting, .interestSetting, .onboardingFlow, .tabNavigation, .meetingDetail, .meetingWidget,
        ]
        XCTAssertTrue(others.allSatisfy(\.selectsAppearance))
    }
}

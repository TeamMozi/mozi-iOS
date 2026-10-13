@testable import MoziDemoKit
import UIKit
import XCTest

@MainActor
final class DemoMenuPassThroughWindowTests: XCTestCase {
    private let buttonFrame = CGRect(x: 300, y: 700, width: 52, height: 52)

    func test_데모_버튼_창은_앱_창과_그_덮개보다_위에_뜬다() {
        XCTAssertGreaterThan(DemoMenuPassThroughWindow.level, UIWindow.Level.normal)
        XCTAssertLessThan(DemoMenuPassThroughWindow.level, UIWindow.Level.alert)
        XCTAssertEqual(DemoMenuPassThroughWindow(frame: .zero).windowLevel, DemoMenuPassThroughWindow.level)
    }

    func test_버튼_자리_안의_터치만_받는다() {
        let inside = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
        let outside = CGPoint(x: 40, y: 200)

        XCTAssertTrue(accepts(inside, false))
        XCTAssertFalse(accepts(outside, false))
    }

    func test_데모_메뉴가_떠_있으면_모든_터치를_받는다() {
        let outside = CGPoint(x: 40, y: 200)

        XCTAssertTrue(accepts(outside, true))
    }

    func test_버튼_자리가_비면_아무_터치도_받지_않는다() {
        XCTAssertFalse(accepts(.zero, .null, false))
    }

    func test_버튼_밖_터치는_아래_창으로_넘긴다() {
        let window = DemoMenuPassThroughWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UIViewController()
        window.buttonFrame = buttonFrame
        window.isHidden = false

        XCTAssertNil(window.hitTest(CGPoint(x: 40, y: 200), with: nil))
        XCTAssertNotNil(window.hitTest(CGPoint(x: buttonFrame.midX, y: buttonFrame.midY), with: nil))
    }

    func test_앱_창은_데모_버튼_창이_아닌_보통_높이_창이다() {
        let overlay = DemoMenuPassThroughWindow(frame: .zero)
        let app = UIWindow(frame: .zero)

        XCTAssertTrue(DemoMenuPassThroughWindow.appWindow(among: [overlay, app]) === app)
        XCTAssertTrue(DemoMenuPassThroughWindow.appWindow(among: [app, overlay]) === app)
    }

    func test_데모_버튼_창의_높이를_보통으로_바꿔도_앱_창으로_고르지_않는다() {
        let overlay = DemoMenuPassThroughWindow(frame: .zero)
        overlay.windowLevel = .normal

        XCTAssertNil(DemoMenuPassThroughWindow.appWindow(among: [overlay]))
    }

    func test_보통_높이가_아닌_창은_앱_창으로_고르지_않는다() {
        let alert = UIWindow(frame: .zero)
        alert.windowLevel = .alert
        let app = UIWindow(frame: .zero)

        XCTAssertTrue(DemoMenuPassThroughWindow.appWindow(among: [alert, app]) === app)
        XCTAssertNil(DemoMenuPassThroughWindow.appWindow(among: [alert]))
    }

    private func accepts(_ point: CGPoint, _ menuPresented: Bool) -> Bool {
        accepts(point, buttonFrame, menuPresented)
    }

    private func accepts(_ point: CGPoint, _ frame: CGRect, _ menuPresented: Bool) -> Bool {
        DemoMenuPassThroughWindow.acceptsTouch(at: point, buttonFrame: frame, isMenuPresented: menuPresented)
    }
}

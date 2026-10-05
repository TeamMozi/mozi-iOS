@testable import SharedDesignSystem
import SwiftUI
import XCTest

final class DesignButtonFoundationTests: XCTestCase {
    func test_비활성이면_눌려도_비활성이다() {
        XCTAssertEqual(DesignButtonState(isEnabled: false, isPressed: false), .disabled)
        XCTAssertEqual(DesignButtonState(isEnabled: false, isPressed: true), .disabled)
    }

    func test_활성이면_눌림에_따라_기본이나_눌림이다() {
        XCTAssertEqual(DesignButtonState(isEnabled: true, isPressed: false), .default)
        XCTAssertEqual(DesignButtonState(isEnabled: true, isPressed: true), .pressed)
    }

    func test_눌림_불투명도는_눌리면_0점88_아니면_1이다() {
        XCTAssertEqual(DesignButtonPressedOpacity.value(isPressed: true), 0.88)
        XCTAssertEqual(DesignButtonPressedOpacity.value(isPressed: false), 1)
    }

    @MainActor
    func test_아이콘_버튼은_글자와_아이콘_Label을_쓴다() {
        let button = Button("확인", icon: Image.ds.icon.check.outlined) {}
        XCTAssertTrue(type(of: button) == Button<SwiftUI.Label<Text, Image>>.self)
    }
}

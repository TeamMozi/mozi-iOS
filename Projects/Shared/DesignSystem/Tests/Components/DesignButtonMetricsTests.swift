import XCTest
@testable import SharedDesignSystem

final class DesignButtonMetricsTests: XCTestCase {
    func test_버튼_사이즈_메트릭스() {
        XCTAssertEqual(DesignButtonSize.sm.height, 32)
        XCTAssertEqual(DesignButtonSize.sm.horizontalPadding, 12)
        XCTAssertEqual(DesignButtonSize.sm.cornerRadius, 4)
        XCTAssertEqual(DesignButtonSize.sm.iconSize, 14)

        XCTAssertEqual(DesignButtonSize.md.height, 40)
        XCTAssertEqual(DesignButtonSize.md.horizontalPadding, 16)
        XCTAssertEqual(DesignButtonSize.md.cornerRadius, 4)
        XCTAssertEqual(DesignButtonSize.md.iconSize, 16)

        XCTAssertEqual(DesignButtonSize.lg.height, 48)
        XCTAssertEqual(DesignButtonSize.lg.horizontalPadding, 20)
        XCTAssertEqual(DesignButtonSize.lg.cornerRadius, 8)
        XCTAssertEqual(DesignButtonSize.lg.iconSize, 18)
    }

    func test_primary_disabled가_시맨틱_토큰_사용() {
        let style = DesignButtonStyleResolver.resolve(variant: .primary, state: .disabled)
        XCTAssertEqual(style.background.hexRGB, PrimitiveColor.Primary._50.hexRGB)
        XCTAssertEqual(style.content.hexRGB, PrimitiveColor.Neutral._500.hexRGB)
    }

    func test_outlined_pressed_배경_토큰() {
        let style = DesignButtonStyleResolver.resolve(variant: .outlined, state: .pressed)
        XCTAssertEqual(style.background.hexRGB, PrimitiveColor.Primary._900.hexRGB)
        XCTAssertEqual(style.border?.hexRGB, PrimitiveColor.Primary._300.hexRGB)
    }

    func test_disabled_상태_해석() {
        // 부모 `.disabled` / `DesignButton(isEnabled: false)` 가 disabled 토큰을 쓰는지 검증한다.
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: false, isPressed: false),
            .disabled
        )
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: false, isPressed: true),
            .disabled
        )
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: true, isPressed: true),
            .pressed
        )
        XCTAssertEqual(
            DesignButtonInteractionStateResolver.resolve(isEnabled: true, isPressed: false),
            .default
        )
    }
}

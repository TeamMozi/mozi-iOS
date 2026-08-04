import XCTest
@testable import SharedDesignSystem

final class DesignButtonMetricsTests: XCTestCase {
    func test_size_metrics() {
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

    func test_primary_disabled_uses_semantic_tokens() {
        let style = DesignButtonStyleResolver.resolve(variant: .primary, state: .disabled)
        XCTAssertEqual(style.background.hexRGB, PrimitiveColor.Primary._50.hexRGB)
        XCTAssertEqual(style.content.hexRGB, PrimitiveColor.Neutral._500.hexRGB)
    }

    func test_outlined_pressed_background() {
        let style = DesignButtonStyleResolver.resolve(variant: .outlined, state: .pressed)
        XCTAssertEqual(style.background.hexRGB, PrimitiveColor.Primary._900.hexRGB)
        XCTAssertEqual(style.border?.hexRGB, PrimitiveColor.Primary._300.hexRGB)
    }

    func test_disabled_state_resolution() {
        // Covers parent .disabled / DesignButton(isEnabled: false) → disabled tokens.
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

import SwiftUI
import XCTest
@testable import SharedDesignSystem

final class SemanticColorTests: XCTestCase {
    func test_button_primary_default_maps_primary300() {
        XCTAssertEqual(
            SemanticColor.Button.Primary.background.default.hexRGB,
            PrimitiveColor.Primary._300.hexRGB
        )
    }

    func test_button_primary_disabled_content_maps_neutral500() {
        XCTAssertEqual(
            SemanticColor.Button.Primary.content.disabled.hexRGB,
            PrimitiveColor.Neutral._500.hexRGB
        )
    }

    func test_text_neutral_white_maps_neutral0() {
        XCTAssertEqual(
            SemanticColor.Text.Neutral.white.hexRGB,
            PrimitiveColor.Neutral._0.hexRGB
        )
    }

    func test_brand_kakao_maps_brand_token() {
        XCTAssertEqual(
            SemanticColor.Social.kakao.hexRGB,
            PrimitiveColor.Social.kakaoYellow.hexRGB
        )
        XCTAssertEqual(
            SemanticColor.Social.kakaoContent.hexRGB,
            PrimitiveColor.Neutral._1000.hexRGB
        )
        XCTAssertEqual(
            SemanticColor.Social.appleContent.hexRGB,
            PrimitiveColor.Neutral._1000.hexRGB
        )
    }

    func test_button_secondary_default_maps_secondary500() {
        XCTAssertEqual(
            SemanticColor.Button.Secondary.background.default.hexRGB,
            PrimitiveColor.Secondary._500.hexRGB
        )
    }

    func test_button_outlined_default_is_clear() {
        let background = SemanticColor.Button.Outlined.background.default
        XCTAssertEqual(background.hexRGB, 0x000000)
        XCTAssertEqual(background.alpha, 0, accuracy: 0.0001)
    }

    func test_button_text_pressed_background_maps_primary900() {
        XCTAssertEqual(
            SemanticColor.Button.Text.background.pressed.hexRGB,
            PrimitiveColor.Primary._900.hexRGB
        )
    }

    func test_background_grayDarker_maps_neutral900() {
        XCTAssertEqual(
            SemanticColor.Background.grayDarker.hexRGB,
            PrimitiveColor.Neutral._900.hexRGB
        )
    }

    func test_border_primary_basic_maps_primary300() {
        XCTAssertEqual(
            SemanticColor.Border.Primary.basic.hexRGB,
            PrimitiveColor.Primary._300.hexRGB
        )
    }

    func test_dim_default_is_black_40_percent() {
        let dim = SemanticColor.Dim.default
        XCTAssertEqual(dim.hexRGB, 0x000000)
        XCTAssertEqual(dim.alpha, 0.4, accuracy: 0.0001)
    }

    func test_public_color_ds_paths_resolve() {
        XCTAssertNotNil(Color.ds.button.primary.background.default)
        XCTAssertNotNil(Color.ds.text.neutral.basic)
        XCTAssertNotNil(Color.ds.background.grayDarker)
        XCTAssertNotNil(Color.ds.border.primary.basic)
        XCTAssertNotNil(Color.ds.dim.default)
        XCTAssertNotNil(Color.ds.social.kakao)
    }
}

import SwiftUI
import XCTest
@testable import SharedDesignSystem

final class SemanticColorTests: XCTestCase {
    func test_버튼_primary_default가_primary300_매핑() {
        XCTAssertEqual(
            SemanticColor.Button.Primary.background.default.hexRGB,
            PrimitiveColor.Primary._300.hexRGB
        )
    }

    func test_버튼_primary_disabled_content가_neutral500_매핑() {
        XCTAssertEqual(
            SemanticColor.Button.Primary.content.disabled.hexRGB,
            PrimitiveColor.Neutral._500.hexRGB
        )
    }

    func test_텍스트_neutral_white가_neutral0_매핑() {
        XCTAssertEqual(
            SemanticColor.Text.Neutral.white.hexRGB,
            PrimitiveColor.Neutral._0.hexRGB
        )
    }

    func test_카카오_시맨틱_컬러가_브랜드_토큰_매핑() {
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

    func test_버튼_secondary_default가_secondary500_매핑() {
        XCTAssertEqual(
            SemanticColor.Button.Secondary.background.default.hexRGB,
            PrimitiveColor.Secondary._500.hexRGB
        )
    }

    func test_버튼_outlined_default_배경이_clear() {
        let background = SemanticColor.Button.Outlined.background.default
        XCTAssertEqual(background.hexRGB, 0x000000)
        XCTAssertEqual(background.alpha, 0, accuracy: 0.0001)
    }

    func test_버튼_text_pressed_배경이_primary900_매핑() {
        XCTAssertEqual(
            SemanticColor.Button.Text.background.pressed.hexRGB,
            PrimitiveColor.Primary._900.hexRGB
        )
    }

    func test_background_grayDarker가_neutral900_매핑() {
        XCTAssertEqual(
            SemanticColor.Background.grayDarker.hexRGB,
            PrimitiveColor.Neutral._900.hexRGB
        )
    }

    func test_border_primary_basic이_primary300_매핑() {
        XCTAssertEqual(
            SemanticColor.Border.Primary.basic.hexRGB,
            PrimitiveColor.Primary._300.hexRGB
        )
    }

    func test_dim_default가_검정_40퍼센트() {
        let dim = SemanticColor.Dim.default
        XCTAssertEqual(dim.hexRGB, 0x000000)
        XCTAssertEqual(dim.alpha, 0.4, accuracy: 0.0001)
    }

    func test_공개_Color_ds_경로가_해석됨() {
        XCTAssertNotNil(Color.ds.button.primary.background.default)
        XCTAssertNotNil(Color.ds.text.neutral.basic)
        XCTAssertNotNil(Color.ds.background.grayDarker)
        XCTAssertNotNil(Color.ds.border.primary.basic)
        XCTAssertNotNil(Color.ds.dim.default)
        XCTAssertNotNil(Color.ds.social.kakao)
    }
}

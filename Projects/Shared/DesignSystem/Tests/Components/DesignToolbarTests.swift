@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

// 화면 타입의 static 값은 메인 액터에 묶이므로 그 값을 읽는 테스트는 @MainActor 다.
final class DesignToolbarTests: XCTestCase {
    @MainActor
    func test_툴바_제목은_Pretendard_Medium_16_줄_22_자간_마이너스_2퍼센트다() {
        XCTAssertEqual(DesignToolbarTitle.style, TextStyle.ds.headline.medium)
        XCTAssertEqual(DesignToolbarTitle.style.fontName, "Pretendard-Medium")
        XCTAssertEqual(DesignToolbarTitle.style.size, 16)
        XCTAssertEqual(DesignToolbarTitle.style.lineHeight, 22)
        XCTAssertEqual(DesignToolbarTitle.style.letterSpacingEm, -0.02)
    }

    @MainActor
    func test_툴바_제목과_아이콘은_text_neutral_primary_색이다() {
        XCTAssertEqual(DesignToolbarTitle.color, SemanticColor.text.neutral.primary)
        XCTAssertEqual(DesignToolbarIcon.color, SemanticColor.text.neutral.primary)
    }

    @MainActor
    func test_툴바_아이콘은_24pt로_그린다() throws {
        XCTAssertEqual(DesignToolbarIcon.size, 24)

        let renderer = ImageRenderer(content: DesignToolbarIcon(Image.ds.icon.close.outlined))
        renderer.scale = 1
        let cgImage = try XCTUnwrap(renderer.cgImage)
        XCTAssertEqual(cgImage.width, 24)
        XCTAssertEqual(cgImage.height, 24)
    }

    func test_헤더_배경은_투명이면_칠하지_않고_채움이면_fill_neutral_default다() {
        XCTAssertNil(DesignHeaderBackground.transparent.fill)
        XCTAssertEqual(DesignHeaderBackground.filled.fill, SemanticColor.fill.neutral.default)
    }

    @MainActor
    func test_뒤로_가기_그림은_chevron_left_24pt_템플릿이다() {
        let image = DesignNavigationBar.backIndicatorImage
        XCTAssertEqual(image.size, CGSize(width: 24, height: 24))
        XCTAssertEqual(image.renderingMode, .alwaysTemplate)
    }

    @MainActor
    func test_내비게이션_바_모양은_바탕이_투명하고_뒤로_가기_그림이_24pt다() {
        let appearance = DesignNavigationBar.makeAppearance()
        XCTAssertNil(appearance.backgroundEffect)
        XCTAssertEqual(appearance.backIndicatorImage.size, CGSize(width: 24, height: 24))
        XCTAssertEqual(appearance.backIndicatorTransitionMaskImage.size, CGSize(width: 24, height: 24))
    }
}

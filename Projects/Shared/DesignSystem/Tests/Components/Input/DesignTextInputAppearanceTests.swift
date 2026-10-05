@testable import SharedDesignSystem
import UIKit
import XCTest

final class DesignTextInputAppearanceTests: XCTestCase {
    @MainActor
    func test_의미_색의_UIKit_색은_기기_모드를_따른다() {
        let color = SemanticColor.text.neutral.primary.uiColor
        XCTAssertEqual(rgba(color, in: .dark), 0xFCFCFCFF)
        XCTAssertEqual(rgba(color, in: .light), 0x0E0E11FF)
        XCTAssertEqual(rgba(color, in: .unspecified), 0xFCFCFCFF)
    }

    func test_UIKit_글꼴은_글자_스타일의_Pretendard다() {
        let font = TextStyle.ds.body.regular.uiFont
        XCTAssertEqual(font.fontName, "Pretendard-Regular")
        XCTAssertEqual(font.pointSize, 16)
    }

    func test_여러_줄_글자_속성은_줄_높이와_자간을_건다() throws {
        let attributes = DesignTextInputAppearance.testBody.textAttributes(includesLineHeight: true)
        let paragraph = try XCTUnwrap(attributes[.paragraphStyle] as? NSParagraphStyle)
        XCTAssertEqual(paragraph.minimumLineHeight, 24)
        XCTAssertEqual(paragraph.maximumLineHeight, 24)
        XCTAssertEqual(try XCTUnwrap(attributes[.kern] as? CGFloat), -0.16, accuracy: 0.0001)
    }

    func test_한_줄_글자_속성은_줄_높이를_걸지_않는다() {
        let attributes = DesignTextInputAppearance.testBody.textAttributes(includesLineHeight: false)
        XCTAssertNil(attributes[.paragraphStyle])
    }
}

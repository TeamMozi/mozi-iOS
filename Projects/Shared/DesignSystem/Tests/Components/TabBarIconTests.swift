@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

final class TabBarIconTests: XCTestCase {
    func test_탭_아이콘은_숏폼_검색_채팅_마이_만들기_순서로_다섯이다() {
        XCTAssertEqual(TabBarIcon.allCases, [.playStack, .search, .chat, .person, .plus])
    }

    func test_선택된_탭은_채움_모양이고_나머지는_선_모양이다() {
        let expected: [TabBarIcon: (filled: String, outlined: String)] = [
            .playStack: ("icon_play_stack_filled", "icon_play_stack_outlined"),
            .search: ("icon_search_filled", "icon_search_outlined"),
            .chat: ("icon_chat_filled", "icon_chat_outlined"),
            .person: ("icon_person_filled", "icon_person_outlined"),
        ]
        for (icon, names) in expected {
            XCTAssertEqual(icon.asset(isSelected: true).name, names.filled)
            XCTAssertEqual(icon.asset(isSelected: false).name, names.outlined)
        }
    }

    func test_만들기_탭은_선택과_상관없이_채움_모양이다() {
        XCTAssertEqual(TabBarIcon.plus.asset(isSelected: true).name, "icon_plus_filled")
        XCTAssertEqual(TabBarIcon.plus.asset(isSelected: false).name, "icon_plus_filled")
    }

    func test_만들기_탭만_강조_글자_색이고_나머지는_기본_글자_색이다() {
        XCTAssertEqual(TabBarIcon.plus.theme, SemanticColor.text.accent.default)
        for icon in [TabBarIcon.playStack, .search, .chat, .person] {
            XCTAssertEqual(icon.theme, SemanticColor.text.neutral.primary, "\(icon)")
        }
    }

    func test_라이트_모드만_라이트_그림이고_다크_모드는_다크_그림이다() {
        XCTAssertEqual(TabBarIcon.style(for: .light), .light)
        XCTAssertEqual(TabBarIcon.style(for: .dark), .dark)
    }

    @MainActor
    func test_탭_그림은_28pt이고_시스템_색에_덮이지_않게_원본으로_그린다() {
        for icon in TabBarIcon.allCases {
            for isSelected in [true, false] {
                let image = icon.uiImage(isSelected: isSelected, style: .dark)
                XCTAssertEqual(image.size, CGSize(width: 28, height: 28), "\(icon)")
                XCTAssertEqual(image.renderingMode, .alwaysOriginal, "\(icon)")
            }
        }
    }

    @MainActor
    func test_만들기_탭_그림은_다크에서_FFF489_라이트에서_F6BB09다() throws {
        try assertPainted(TabBarIcon.plus.uiImage(isSelected: false, style: .dark), rgb: 0xFFF489)
        try assertPainted(TabBarIcon.plus.uiImage(isSelected: true, style: .dark), rgb: 0xFFF489)
        try assertPainted(TabBarIcon.plus.uiImage(isSelected: false, style: .light), rgb: 0xF6BB09)
    }

    @MainActor
    func test_나머지_탭_그림은_다크에서_FCFCFC_라이트에서_0E0E11이다() throws {
        try assertPainted(TabBarIcon.search.uiImage(isSelected: true, style: .dark), rgb: 0xFCFCFC)
        try assertPainted(TabBarIcon.person.uiImage(isSelected: false, style: .dark), rgb: 0xFCFCFC)
        try assertPainted(TabBarIcon.playStack.uiImage(isSelected: true, style: .light), rgb: 0x0E0E11)
    }

    /// 완전히 칠해진 화소가 있고, 그 화소가 모두 기대 색(채널마다 ±2)인지 본다.
    private func assertPainted(
        _ image: UIImage,
        rgb: UInt32,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let cgImage = try XCTUnwrap(image.cgImage, file: file, line: line)
        let width = cgImage.width
        let height = cgImage.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        XCTAssertTrue(drawn, file: file, line: line)

        let expected = [Int((rgb >> 16) & 0xFF), Int((rgb >> 8) & 0xFF), Int(rgb & 0xFF)]
        let opaque = stride(from: 0, to: bytes.count, by: 4).filter { bytes[$0 + 3] == 255 }
        XCTAssertFalse(opaque.isEmpty, "칠해진 화소가 없다", file: file, line: line)
        for index in opaque {
            let actual = [Int(bytes[index]), Int(bytes[index + 1]), Int(bytes[index + 2])]
            guard zip(actual, expected).allSatisfy({ abs($0 - $1) <= 2 }) else {
                XCTFail("화소 \(actual) 이 기대 \(expected) 와 다르다", file: file, line: line)
                return
            }
        }
    }
}

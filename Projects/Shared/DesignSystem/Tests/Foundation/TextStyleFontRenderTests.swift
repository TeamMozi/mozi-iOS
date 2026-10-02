@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

/// 호스트 앱 없는 테스트에서 `TextStyle` 글꼴이 Pretendard 로 그려지는지 본다.
/// 이 파일은 글꼴을 직접 등록하지 않는다. `TextStyle.font` 가 스스로 등록해야 통과한다.
final class TextStyleFontRenderTests: XCTestCase {
    @MainActor
    func test_TextStyle_글꼴로_그린_글자가_Pretendard_로_그린_글자와_같다() throws {
        let drawnWithStyle = try render(Text(sampleText).font(TextStyle.ds.title1.bold.font))

        let pretendard = try XCTUnwrap(
            UIFont(name: "Pretendard-Bold", size: 28),
            "TextStyle 이 글꼴을 등록하지 않았다"
        )
        let drawnWithPretendard = try render(Text(sampleText).font(Font(pretendard)))

        XCTAssertEqual(drawnWithStyle, drawnWithPretendard)
    }

    @MainActor
    func test_TextStyle_글꼴로_그린_글자가_시스템_글꼴로_그린_글자와_다르다() throws {
        let drawnWithStyle = try render(Text(sampleText).font(TextStyle.ds.title1.bold.font))
        let drawnWithSystem = try render(Text(sampleText).font(.system(size: 28, weight: .bold)))

        XCTAssertNotEqual(drawnWithStyle, drawnWithSystem)
    }

    /// 보이지 않는 창에 `UIHostingController` 로 올려 `window.layer.render(in:)` 로 그린다.
    /// `ImageRenderer` 는 스크롤 안을 비워 그리고, `drawHierarchy` 는 호스트 앱 없는 테스트에서 빈 그림을 낸다.
    @MainActor
    private func render(_ view: some View) throws -> Data {
        let size = CGSize(width: 320, height: 120)
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        // `Font.custom(_:size:)` 는 기기 글자 크기를 따른다. 기본 크기 .large 로 고정해야 고정 크기 UIFont 와 같게 그린다.
        let host = UIHostingController(
            rootView: view.dynamicTypeSize(.large).frame(width: size.width, height: size.height)
        )
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = window.bounds
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        window.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
        let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        window.isHidden = true
        window.rootViewController = nil
        return try XCTUnwrap(image.pngData(), "PNG 로 바꾸지 못했다")
    }
}

private let sampleText = "모지 Mozi 123"

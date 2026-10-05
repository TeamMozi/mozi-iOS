@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

/// 여러 줄·캡션 칸의 placeholder 와 입력 글자가 같은 높이에 그려지는지, placeholder 가 글자가 있을 때 숨는지,
/// 라벨 줄 높이가 22 인지 본다.
final class DesignInputRenderTests: XCTestCase {
    @MainActor
    func test_여러_줄_칸_placeholder는_입력_글자와_같은_높이에_그려진다() throws {
        try assertPlaceholderMatchesText(style: .standard)
    }

    @MainActor
    func test_캡션_칸_placeholder는_입력_글자와_같은_높이에_그려진다() throws {
        try assertPlaceholderMatchesText(style: .caption)
    }

    @MainActor
    func test_placeholder는_비었을_때만_보이고_조합_중에도_숨는다() async throws {
        let (window, root) = showInKeyWindow(TextAreaProbeView())
        defer { window.isHidden = true }
        try await spinMainLoop()
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)
        let placeholder = try XCTUnwrap(
            findSubviews(of: UILabel.self, in: textView).first { $0.text == TextAreaProbeView.placeholder }
        )
        XCTAssertFalse(placeholder.isHidden, "빈 칸")
        XCTAssertFalse(placeholder.isAccessibilityElement)

        textView.becomeFirstResponder()
        textView.setMarkedText("ㄱ", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertTrue(placeholder.isHidden, "조합 중")

        textView.unmarkText()
        textView.insertText("나")
        XCTAssertTrue(placeholder.isHidden, "글자 있음")

        textView.deleteBackward()
        textView.deleteBackward()
        XCTAssertEqual(textView.text, "")
        XCTAssertFalse(placeholder.isHidden, "다 지움")
    }

    @MainActor
    func test_라벨_줄은_높이_22다() {
        let host = UIHostingController(
            rootView: DesignInputLabel(title: "생년월일", isRequired: true).dynamicTypeSize(.large)
        )
        let size = host.sizeThatFits(in: CGSize(width: 320, height: 1000))
        XCTAssertEqual(size.height, 22)
    }

    /// 빈 칸(placeholder 도 비움)과 견줘 처음 달라지는 줄이 글자 윗끝이다. 글자 수는 칸 아래라 윗끝에 걸리지 않는다.
    @MainActor
    private func assertPlaceholderMatchesText(style: DesignTextAreaStyle) throws {
        let blank = try render(text: "", placeholder: "", style: style)
        let placeholder = try render(text: "", placeholder: sample, style: style)
        let typed = try render(text: sample, placeholder: "", style: style)

        let placeholderTop = try XCTUnwrap(firstDifferentRow(placeholder, blank), "placeholder 가 안 그려졌다")
        let typedTop = try XCTUnwrap(firstDifferentRow(typed, blank), "입력 글자가 안 그려졌다")
        XCTAssertEqual(
            CGFloat(placeholderTop) / scale,
            CGFloat(typedTop) / scale,
            accuracy: 0.5,
            "placeholder \(placeholderTop)px · 입력 글자 \(typedTop)px (배율 \(scale))"
        )
    }

    /// `window.layer.render(in:)` 로 그린다. `drawHierarchy` 는 호스트 앱 없는 테스트에서 빈 그림을 낸다.
    @MainActor
    private func render(text: String, placeholder: String, style: DesignTextAreaStyle) throws -> RenderedPixels {
        let size = CGSize(width: 320, height: 200)
        let area = DesignTextArea(text: .constant(text), placeholder: placeholder, maxLength: 50, style: style)
        let view = VStack(spacing: 0) {
            area
            Spacer(minLength: 0)
        }
        .dynamicTypeSize(.large)
        .frame(width: size.width, height: size.height)
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        let host = UIHostingController(rootView: view)
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = window.bounds
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        window.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        window.isHidden = true
        window.rootViewController = nil
        let cgImage = try XCTUnwrap(image.cgImage)
        return try XCTUnwrap(RenderedPixels(cgImage), "픽셀을 읽지 못했다")
    }

    private func firstDifferentRow(_ lhs: RenderedPixels, _ rhs: RenderedPixels) -> Int? {
        (0..<lhs.height).first { row in
            (0..<lhs.width * 4).contains { column in
                let index = row * lhs.width * 4 + column
                return abs(Int(lhs.bytes[index]) - Int(rhs.bytes[index])) > 24
            }
        }
    }

    private let scale: CGFloat = 3
    private let sample = "가나다 Mozi"
}

private struct TextAreaProbeView: View {
    static let placeholder = "소개(선택)"
    @State private var text = ""

    var body: some View {
        DesignTextArea(text: $text, placeholder: Self.placeholder, maxLength: 50)
    }
}

private struct RenderedPixels {
    let width: Int
    let height: Int
    let bytes: [UInt8]

    init?(_ image: CGImage) {
        width = image.width
        height = image.height
        var buffer = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = buffer.withUnsafeMutableBytes { pointer -> Bool in
            guard let context = CGContext(
                data: pointer.baseAddress,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            return true
        }
        guard drawn else { return nil }
        bytes = buffer
    }
}

@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

/// 여러 줄 칸이 쓰는 쪽에 커서 위치(UTF-16)를 알리는지 본다. 모임 정보 칩이 커서 자리에 머리말을 넣는 데 쓴다.
final class DesignTextAreaCursorTests: XCTestCase {
    @MainActor
    func test_여러줄_칸에서_커서를_옮기면_쓰는_쪽_커서_값이_그_자리가_된다() async throws {
        let probe = CursorProbe()
        let (window, root) = showInKeyWindow(CursorProbeView(probe: probe))
        defer { window.isHidden = true }
        try await spinMainLoop()
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)

        XCTAssertTrue(textView.becomeFirstResponder())
        textView.selectedRange = NSRange(location: 2, length: 0)
        try await spinMainLoop()

        XCTAssertEqual(probe.cursor, 2)
    }

    @MainActor
    func test_여러줄_칸이_키보드를_놓으면_커서_값이_비워진다() async throws {
        let probe = CursorProbe()
        let (window, root) = showInKeyWindow(CursorProbeView(probe: probe))
        defer { window.isHidden = true }
        try await spinMainLoop()
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)

        XCTAssertTrue(textView.becomeFirstResponder())
        textView.selectedRange = NSRange(location: 1, length: 0)
        try await spinMainLoop()
        XCTAssertTrue(textView.resignFirstResponder())
        try await spinMainLoop()

        XCTAssertNil(probe.cursor)
    }
}

@MainActor
@Observable
private final class CursorProbe {
    var text = "가나다라"
    var cursor: Int?
}

private struct CursorProbeView: View {
    @Bindable var probe: CursorProbe

    var body: some View {
        DesignTextArea("소개", text: $probe.text, placeholder: "소개", maxLength: 50, cursor: $probe.cursor)
    }
}

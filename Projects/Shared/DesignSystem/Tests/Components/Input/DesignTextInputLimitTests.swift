@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

/// UIKit 칸에 글자 수 규칙이 걸리는지 본다.
/// 프로그램으로 넣은 글자는 `UITextField` 위임과 `editingChanged` 를 부르지 않으므로 위임 메서드를 직접 부른다.
/// 조합 상태(`markedTextRange`)는 `setMarkedText` 로 실제로 만든다. `UITextView` 는 `textViewDidChange` 가 스스로 불린다.
final class DesignTextInputLimitTests: XCTestCase {
    private let single = DesignTextLimit(maxLength: 50, overflow: .truncate)
    private let multi = DesignTextLimit(maxLength: 50, overflow: .keep)

    @MainActor
    func test_한_줄_칸은_최대에서_한_글자를_더_받지_않는다() {
        let box = TextBox(hangul(50))
        let harness = FieldHarness(box: box, limit: single)
        defer { harness.window.isHidden = true }

        let accepted = harness.coordinator.textField(
            harness.field,
            shouldChangeCharactersIn: NSRange(location: 50, length: 0),
            replacementString: "가"
        )

        XCTAssertFalse(accepted)
        XCTAssertEqual(box.value, hangul(50))
    }

    @MainActor
    func test_한_줄_칸은_조합_중이면_최대에서도_글자를_받는다() {
        let box = TextBox(hangul(50))
        let harness = FieldHarness(box: box, limit: single)
        defer { harness.window.isHidden = true }
        XCTAssertTrue(harness.field.becomeFirstResponder())
        harness.field.setMarkedText("ㅎ", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(harness.field.markedTextRange)

        let accepted = harness.coordinator.textField(
            harness.field,
            shouldChangeCharactersIn: NSRange(location: 50, length: 1),
            replacementString: "하"
        )

        XCTAssertTrue(accepted)
    }

    @MainActor
    func test_한_줄_칸에_붙여넣은_긴_글은_최대까지만_들어간다() {
        let box = TextBox(hangul(48))
        let harness = FieldHarness(box: box, limit: single)
        defer { harness.window.isHidden = true }

        let accepted = harness.coordinator.textField(
            harness.field,
            shouldChangeCharactersIn: NSRange(location: 48, length: 0),
            replacementString: "나다라마"
        )

        XCTAssertFalse(accepted, "칸이 잘린 글을 직접 넣는다")
        XCTAssertEqual(harness.field.text, hangul(48) + "나다")
        XCTAssertEqual(box.value, hangul(48) + "나다")
    }

    @MainActor
    func test_한_줄_칸은_조합이_끝나면_넘친_글자를_자른다() {
        let box = TextBox(hangul(49))
        let harness = FieldHarness(box: box, limit: single)
        defer { harness.window.isHidden = true }
        XCTAssertTrue(harness.field.becomeFirstResponder())

        harness.field.setMarkedText("나다", selectedRange: NSRange(location: 2, length: 0))
        harness.coordinator.editingChanged(harness.field)
        XCTAssertEqual(box.value.count, 51, "조합 중에는 자르지 않는다")

        harness.field.unmarkText()
        harness.coordinator.editingChanged(harness.field)
        XCTAssertEqual(harness.field.text, hangul(49) + "나")
        XCTAssertEqual(box.value, hangul(49) + "나")
    }

    @MainActor
    func test_한_줄_칸은_넘어온_긴_값을_잘라_쓰는_쪽_값도_바꾼다() async throws {
        let box = TextBox(hangul(55))
        let bridge = DesignTextFieldBridge(text: box.binding, appearance: .testBody, limit: single) { _ in }
        let (window, root) = showInKeyWindow(bridge.frame(height: 44))
        defer { window.isHidden = true }
        try await spinMainLoop()

        let field = try XCTUnwrap(findSubviews(of: UITextField.self, in: root).first)
        XCTAssertEqual(field.text, hangul(50))
        XCTAssertEqual(box.value, hangul(50))
    }

    @MainActor
    func test_여러_줄_칸은_넘어온_긴_값을_그대로_둔다() async throws {
        let box = TextBox(hangul(55))
        let bridge = DesignTextViewBridge(text: box.binding, appearance: .testBody, limit: multi) { _ in }
        let (window, root) = showInKeyWindow(bridge.frame(height: 100))
        defer { window.isHidden = true }
        try await spinMainLoop()

        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)
        XCTAssertEqual(textView.text, hangul(55))
        XCTAssertEqual(box.value, hangul(55))
    }

    @MainActor
    func test_여러_줄_칸은_긴_값에서_한_글자_지우기를_받는다() {
        let box = TextBox(hangul(55))
        let harness = TextViewHarness(box: box, limit: multi)
        defer { harness.window.isHidden = true }

        let accepted = harness.coordinator.textView(
            harness.textView,
            shouldChangeTextIn: NSRange(location: 54, length: 1),
            replacementText: ""
        )

        XCTAssertTrue(accepted)
    }

    @MainActor
    func test_여러_줄_칸은_긴_값에서_한_글자_더하기를_받지_않는다() {
        let box = TextBox(hangul(55))
        let harness = TextViewHarness(box: box, limit: multi)
        defer { harness.window.isHidden = true }

        let accepted = harness.coordinator.textView(
            harness.textView,
            shouldChangeTextIn: NSRange(location: 55, length: 0),
            replacementText: "가"
        )

        XCTAssertFalse(accepted)
        XCTAssertEqual(box.value, hangul(55))
    }

    @MainActor
    func test_여러_줄_칸은_조합이_끝나면_넘친_글자를_자른다() {
        let box = TextBox(hangul(49))
        let harness = TextViewHarness(box: box, limit: multi)
        defer { harness.window.isHidden = true }
        XCTAssertTrue(harness.textView.becomeFirstResponder())

        harness.textView.setMarkedText("나다", selectedRange: NSRange(location: 2, length: 0))
        XCTAssertEqual(box.value.count, 51, "조합 중에는 자르지 않는다")

        harness.textView.unmarkText()
        XCTAssertEqual(harness.textView.text, hangul(49) + "나")
        XCTAssertEqual(box.value, hangul(49) + "나")
    }

    private func hangul(_ count: Int) -> String {
        String(repeating: "가", count: count)
    }
}

/// 바인딩 뒤의 값. 칸이 쓰는 쪽 값을 어떻게 바꿨는지 본다.
@MainActor
private final class TextBox {
    var value: String

    init(_ value: String) {
        self.value = value
    }

    var binding: Binding<String> {
        Binding(get: { self.value }, set: { self.value = $0 })
    }
}

/// 키 창에 올린 `UITextField` 와 그 위임. 위임은 약하게 잡히므로 여기서 붙들어 둔다.
@MainActor
private struct FieldHarness {
    let window: UIWindow
    let field: UITextField
    let coordinator: DesignTextFieldBridge.Coordinator

    init(box: TextBox, limit: DesignTextLimit) {
        let (window, root) = makeKeyWindow()
        let field = UITextField(frame: CGRect(x: 0, y: 100, width: 300, height: 44))
        root.addSubview(field)
        let bridge = DesignTextFieldBridge(text: box.binding, appearance: .testBody, limit: limit) { _ in }
        let coordinator = bridge.makeCoordinator()
        coordinator.configure(field)
        self.window = window
        self.field = field
        self.coordinator = coordinator
    }
}

/// 키 창에 올린 `UITextView` 와 그 위임.
@MainActor
private struct TextViewHarness {
    let window: UIWindow
    let textView: UITextView
    let coordinator: DesignTextViewBridge.Coordinator

    init(box: TextBox, limit: DesignTextLimit) {
        let (window, root) = makeKeyWindow()
        let textView = UITextView(frame: CGRect(x: 0, y: 100, width: 300, height: 100))
        root.addSubview(textView)
        let bridge = DesignTextViewBridge(text: box.binding, appearance: .testBody, limit: limit) { _ in }
        let coordinator = bridge.makeCoordinator()
        coordinator.configure(textView)
        self.window = window
        self.textView = textView
        self.coordinator = coordinator
    }
}

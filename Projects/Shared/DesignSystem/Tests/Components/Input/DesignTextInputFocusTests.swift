@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

/// 스펙 정한 것 8항: 감싼 UIKit 칸과 SwiftUI `.focused($focus, equals:)` 가 양방향으로 이어지는지 본다.
/// 앞의 두 테스트가 통과하면 갈래 A(`.focused` 를 쓴다), 하나라도 실패하면 갈래 B(포커스를 인자로 받는다)다.
final class DesignTextInputFocusTests: XCTestCase {
    @MainActor
    func test_화면이_포커스를_주면_그_칸이_키보드를_띄운다() async throws {
        let probe = FocusProbe()
        let (window, root) = showInKeyWindow(FocusProbeView(probe: probe))
        defer { window.isHidden = true }
        try await spinMainLoop()
        let field = try XCTUnwrap(findSubviews(of: UITextField.self, in: root).first)
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)

        probe.requested = .field
        try await spinMainLoop()
        XCTAssertTrue(field.isFirstResponder, "한 줄 칸")

        probe.requested = .area
        try await spinMainLoop()
        XCTAssertTrue(textView.isFirstResponder, "여러 줄 칸")
        XCTAssertFalse(field.isFirstResponder, "앞 칸은 키보드를 놓는다")

        probe.requested = nil
        try await spinMainLoop()
        XCTAssertFalse(textView.isFirstResponder, "포커스를 거두면 키보드를 내린다")
    }

    @MainActor
    func test_칸을_누르면_화면의_포커스_값이_그_칸이_된다() async throws {
        let probe = FocusProbe()
        let (window, root) = showInKeyWindow(FocusProbeView(probe: probe))
        defer { window.isHidden = true }
        try await spinMainLoop()
        let field = try XCTUnwrap(findSubviews(of: UITextField.self, in: root).first)
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)

        XCTAssertTrue(field.becomeFirstResponder())
        try await spinMainLoop()
        XCTAssertEqual(probe.observed, .field)

        XCTAssertTrue(textView.becomeFirstResponder())
        try await spinMainLoop()
        XCTAssertEqual(probe.observed, .area)

        XCTAssertTrue(textView.resignFirstResponder())
        try await spinMainLoop()
        XCTAssertNil(probe.observed)
    }

    @MainActor
    func test_칸이_키보드를_얻고_잃을_때_알린다() async throws {
        let probe = FocusProbe()
        let (window, root) = showInKeyWindow(FocusProbeView(probe: probe))
        defer { window.isHidden = true }
        try await spinMainLoop()
        let field = try XCTUnwrap(findSubviews(of: UITextField.self, in: root).first)
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)

        XCTAssertTrue(field.becomeFirstResponder())
        try await spinMainLoop()
        XCTAssertTrue(field.resignFirstResponder())
        try await spinMainLoop()
        XCTAssertTrue(textView.becomeFirstResponder())
        try await spinMainLoop()
        XCTAssertTrue(textView.resignFirstResponder())
        try await spinMainLoop()

        XCTAssertEqual(probe.editingEvents, ["한 줄 true", "한 줄 false", "여러 줄 true", "여러 줄 false"])
    }
}

private enum ProbeFocus: Hashable {
    case field
    case area
}

@MainActor
private final class FocusProbe: ObservableObject {
    @Published var requested: ProbeFocus?
    var observed: ProbeFocus?
    var editingEvents: [String] = []
}

private struct FocusProbeView: View {
    @ObservedObject var probe: FocusProbe
    @FocusState private var focus: ProbeFocus?
    @State private var fieldText = ""
    @State private var areaText = ""

    var body: some View {
        VStack {
            DesignTextFieldBridge(text: $fieldText, appearance: .testBody) { isEditing in
                probe.editingEvents.append("한 줄 \(isEditing)")
            }
            .frame(height: 44)
            .focused($focus, equals: .field)

            DesignTextViewBridge(text: $areaText, appearance: .testBody) { isEditing in
                probe.editingEvents.append("여러 줄 \(isEditing)")
            }
            .frame(height: 100)
            .focused($focus, equals: .area)
        }
        .onChange(of: probe.requested) { _, requested in
            focus = requested
        }
        .onChange(of: focus) { _, focused in
            probe.observed = focused
        }
    }
}

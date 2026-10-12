@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

/// 스펙 정한 것 1~4항: 스크롤 시작 시 바로 내리기, 입력 칸 밖 누르기로 내리기, 함께 인식, 입력 칸 거르기.
/// 터치를 흉내 낼 수 없어 누르기 손짓은 설정과 판단 함수(`acceptsTouch(on:at:)`)로 본다.
final class DesignKeyboardDismissalTests: XCTestCase {
    @MainActor
    func test_수식어를_붙이면_스크롤을_시작할_때_키보드를_바로_내린다() async throws {
        let box = ScrollModeBox()
        let (window, _) = showInKeyWindow(ScrollModeProbe(box: box).designKeyboardDismissal())
        defer { window.isHidden = true }
        try await spinMainLoop()

        XCTAssertEqual(box.mode, .immediately)
    }

    @MainActor
    func test_수식어를_붙인_뷰가_창에_오르면_창에_누르기_손짓이_달린다() async throws {
        let (window, root) = showInKeyWindow(KeyboardProbeView())
        defer { window.isHidden = true }
        try await spinMainLoop()
        let tapView = try XCTUnwrap(findSubviews(of: DesignKeyboardDismissalTapView.self, in: root).first)

        XCTAssertTrue((window.gestureRecognizers ?? []).contains { $0 === tapView.tapRecognizer })
    }

    @MainActor
    func test_누르기_손짓은_터치를_막지_않고_다른_손짓과_함께_인식된다() {
        let tapView = DesignKeyboardDismissalTapView(frame: .zero)

        XCTAssertFalse(tapView.tapRecognizer.cancelsTouchesInView, "버튼·메뉴가 터치를 그대로 받는다")
        XCTAssertFalse(tapView.tapRecognizer.delaysTouchesBegan)
        XCTAssertTrue(tapView.tapRecognizer.delegate === tapView)
        XCTAssertTrue(tapView.gestureRecognizer(
            tapView.tapRecognizer,
            shouldRecognizeSimultaneouslyWith: UIPanGestureRecognizer()
        ))
        XCTAssertTrue(tapView.gestureRecognizer(
            tapView.tapRecognizer,
            shouldRecognizeSimultaneouslyWith: UITapGestureRecognizer()
        ))
    }

    @MainActor
    func test_창에서_빠지면_누르기_손짓을_창에서_뗀다() {
        let (window, root) = makeKeyWindow()
        defer { window.isHidden = true }
        let tapView = DesignKeyboardDismissalTapView(frame: root.bounds)

        root.addSubview(tapView)
        XCTAssertTrue((window.gestureRecognizers ?? []).contains { $0 === tapView.tapRecognizer })

        tapView.removeFromSuperview()
        XCTAssertFalse((window.gestureRecognizers ?? []).contains { $0 === tapView.tapRecognizer })
    }

    @MainActor
    func test_한_줄_칸과_여러_줄_칸과_그_안의_뷰는_입력_칸이다() {
        let field = UITextField()
        let fieldChild = UIView()
        field.addSubview(fieldChild)
        let textView = UITextView()
        let textViewChild = UILabel()
        textView.addSubview(textViewChild)

        XCTAssertTrue(DesignKeyboardDismissal.isTextInput(field))
        XCTAssertTrue(DesignKeyboardDismissal.isTextInput(fieldChild))
        XCTAssertTrue(DesignKeyboardDismissal.isTextInput(textView))
        XCTAssertTrue(DesignKeyboardDismissal.isTextInput(textViewChild))
    }

    @MainActor
    func test_입력_칸이_아닌_뷰와_없는_뷰는_입력_칸이_아니다() {
        let container = UIView()
        let label = UILabel()
        container.addSubview(label)

        XCTAssertFalse(DesignKeyboardDismissal.isTextInput(container))
        XCTAssertFalse(DesignKeyboardDismissal.isTextInput(label))
        XCTAssertFalse(DesignKeyboardDismissal.isTextInput(UIScrollView()))
        XCTAssertFalse(DesignKeyboardDismissal.isTextInput(nil))
    }

    @MainActor
    func test_붙인_뷰_안에서_입력_칸이_아닌_곳을_누르면_손짓이_받는다() async throws {
        let (window, root) = showInKeyWindow(KeyboardProbeView())
        defer { window.isHidden = true }
        try await spinMainLoop()
        let tapView = try XCTUnwrap(findSubviews(of: DesignKeyboardDismissalTapView.self, in: root).first)
        XCTAssertGreaterThan(tapView.bounds.height, 0)

        let emptyPoint = CGPoint(x: tapView.bounds.midX, y: tapView.bounds.maxY - 1)
        XCTAssertTrue(tapView.acceptsTouch(on: root, at: emptyPoint))
    }

    @MainActor
    func test_입력_칸을_누르면_손짓이_거른다() async throws {
        let (window, root) = showInKeyWindow(KeyboardProbeView())
        defer { window.isHidden = true }
        try await spinMainLoop()
        let tapView = try XCTUnwrap(findSubviews(of: DesignKeyboardDismissalTapView.self, in: root).first)
        let field = try XCTUnwrap(findSubviews(of: UITextField.self, in: root).first)
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)

        let fieldCenter = tapView.convert(CGPoint(x: field.bounds.midX, y: field.bounds.midY), from: field)
        let textViewCenter = tapView.convert(
            CGPoint(x: textView.bounds.midX, y: textView.bounds.midY),
            from: textView
        )
        XCTAssertFalse(tapView.acceptsTouch(on: field, at: fieldCenter), "한 줄 칸")
        XCTAssertFalse(tapView.acceptsTouch(on: textView, at: textViewCenter), "여러 줄 칸")
    }

    @MainActor
    func test_붙인_뷰_영역_밖을_누르면_손짓이_거른다() async throws {
        let (window, root) = showInKeyWindow(KeyboardProbeView())
        defer { window.isHidden = true }
        try await spinMainLoop()
        let tapView = try XCTUnwrap(findSubviews(of: DesignKeyboardDismissalTapView.self, in: root).first)

        let belowPoint = CGPoint(x: tapView.bounds.midX, y: tapView.bounds.maxY + 1)
        XCTAssertFalse(tapView.acceptsTouch(on: root, at: CGPoint(x: -1, y: -1)))
        XCTAssertFalse(tapView.acceptsTouch(on: root, at: belowPoint))
    }

    @MainActor
    func test_내리기를_부르면_키보드를_가진_한_줄_칸이_키보드를_놓는다() async throws {
        let (window, root) = showInKeyWindow(KeyboardProbeView())
        defer { window.isHidden = true }
        try await spinMainLoop()
        let tapView = try XCTUnwrap(findSubviews(of: DesignKeyboardDismissalTapView.self, in: root).first)
        let field = try XCTUnwrap(findSubviews(of: UITextField.self, in: root).first)

        XCTAssertTrue(field.becomeFirstResponder())
        try await spinMainLoop()
        tapView.dismissKeyboard()
        try await spinMainLoop()

        XCTAssertFalse(field.isFirstResponder)
    }

    @MainActor
    func test_내리기를_부르면_키보드를_가진_여러_줄_칸이_키보드를_놓는다() async throws {
        let (window, root) = showInKeyWindow(KeyboardProbeView())
        defer { window.isHidden = true }
        try await spinMainLoop()
        let tapView = try XCTUnwrap(findSubviews(of: DesignKeyboardDismissalTapView.self, in: root).first)
        let textView = try XCTUnwrap(findSubviews(of: UITextView.self, in: root).first)

        XCTAssertTrue(textView.becomeFirstResponder())
        try await spinMainLoop()
        tapView.dismissKeyboard()
        try await spinMainLoop()

        XCTAssertFalse(textView.isFirstResponder)
    }
}

@MainActor
private final class ScrollModeBox {
    var mode: ScrollDismissesKeyboardMode?
}

private struct ScrollModeProbe: View {
    let box: ScrollModeBox
    @Environment(\.scrollDismissesKeyboardMode) private var mode

    var body: some View {
        Color.clear
            .onAppear { box.mode = mode }
    }
}

/// 프로필 설정 화면 꼴: 스크롤 뷰 안에 한 줄 칸·여러 줄 칸과 빈 자리.
private struct KeyboardProbeView: View {
    @State private var name = ""
    @State private var introduction = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DesignTextField("이름", text: $name, placeholder: "이름", maxLength: 10)
                DesignTextArea("소개", text: $introduction, placeholder: "소개", maxLength: 50)
                Color.clear.frame(height: 300)
            }
        }
        .designKeyboardDismissal()
    }
}

import SwiftUI
import UIKit

/// 여러 줄·캡션 칸의 UIKit 몸통. `UITextView` 를 감싼다.
/// 값은 쓰는 쪽이 들고, 포커스는 감싼 바깥에 건 SwiftUI `.focused` 가 잇는다.
/// placeholder 도 칸 안의 `UILabel` 이 그린다. 입력 글자와 같은 줄 높이·여백을 써야 같은 높이에 놓인다.
struct DesignTextViewBridge: UIViewRepresentable {
    @Binding var text: String
    let appearance: DesignTextInputAppearance
    /// 글자 수 규칙. nil 이면 세지 않는다.
    var limit: DesignTextLimit?
    /// 칸이 키보드를 얻으면 true, 잃으면 false. 입력 중 테두리가 쓴다.
    let onEditingChanged: @MainActor (Bool) -> Void

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        context.coordinator.configure(view)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.apply(appearance, to: view)
        context.coordinator.syncText(of: view)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: DesignTextViewBridge
        private var appliedAppearance: DesignTextInputAppearance?
        /// 조합이 끝났을 때 견줄, 마지막으로 받아 둔 값.
        private var committedText = ""
        private let placeholderLabel = UILabel()
        private var placeholderTop: NSLayoutConstraint?
        private var placeholderLeading: NSLayoutConstraint?
        private var placeholderWidth: NSLayoutConstraint?

        init(parent: DesignTextViewBridge) {
            self.parent = parent
        }

        func configure(_ view: UITextView) {
            view.delegate = self
            view.backgroundColor = .clear
            view.textContainer.lineFragmentPadding = 0
            view.setContentHuggingPriority(.defaultLow, for: .horizontal)
            view.setContentHuggingPriority(.defaultLow, for: .vertical)
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            addPlaceholder(to: view)
            apply(parent.appearance, to: view)
            syncText(of: view)
        }

        /// 모양이 바뀌었을 때만 다시 건다. 조합 중에 속성을 다시 걸면 한글 조합이 끊긴다.
        func apply(_ appearance: DesignTextInputAppearance, to view: UITextView) {
            guard appearance != appliedAppearance, view.markedTextRange == nil else { return }
            appliedAppearance = appearance
            let attributes = appearance.textAttributes(includesLineHeight: true)
            view.typingAttributes = attributes
            view.textContainerInset = appearance.textInsets
            view.tintColor = appearance.tint.uiColor
            view.accessibilityLabel = appearance.accessibilityLabel
            let selection = view.selectedRange
            view.attributedText = NSAttributedString(string: view.text ?? "", attributes: attributes)
            view.selectedRange = selection
            placeholderLabel.attributedText = NSAttributedString(
                string: appearance.placeholder,
                attributes: appearance.placeholderAttributes(includesLineHeight: true)
            )
            placeholderTop?.constant = appearance.textInsets.top
            placeholderLeading?.constant = appearance.textInsets.left
            placeholderWidth?.constant = -(appearance.textInsets.left + appearance.textInsets.right)
            updatePlaceholderVisibility(of: view)
        }

        /// 쓰는 쪽 값을 칸에 옮긴다. 조합 중에는 칸을 건드리지 않는다.
        /// 여러 줄·캡션 칸은 `.keep` 이라 긴 값도 그대로 보인다.
        func syncText(of view: UITextView) {
            guard view.markedTextRange == nil else { return }
            let shown = parent.limit?.incoming(parent.text) ?? parent.text
            if view.text != shown {
                setText(shown, in: view)
            }
            committedText = shown
            if shown != parent.text {
                // 화면을 그리는 도중에 바인딩을 바꾸면 SwiftUI 가 경고한다. 다음 차례로 미룬다.
                Task { @MainActor [weak self] in
                    self?.parent.text = shown
                }
            }
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            guard let limit = parent.limit else { return true }
            let current = textView.text ?? ""
            let decision = limit.decide(
                current: current,
                range: range,
                replacement: text,
                isComposing: textView.markedTextRange != nil
            )
            switch decision {
            case .accept:
                return true
            case .reject:
                return false
            case let .replace(with: fitted):
                let updated = (current as NSString).replacingCharacters(in: range, with: fitted)
                setText(updated, in: textView)
                textView.moveCursor(toUTF16Offset: range.location + (fitted as NSString).length)
                commit(updated)
                return false
            }
        }

        /// 글이 바뀔 때마다 불린다. 조합 중이면 그대로 올리고, 조합이 끝났으면 넘친 만큼 자른 뒤 올린다.
        func textViewDidChange(_ textView: UITextView) {
            updatePlaceholderVisibility(of: textView)
            let current = textView.text ?? ""
            guard textView.markedTextRange == nil, let limit = parent.limit else {
                parent.text = current
                return
            }
            let settled = limit.settle(current, previous: committedText)
            if settled != current {
                setText(settled, in: textView)
            }
            commit(settled)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onEditingChanged(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.onEditingChanged(false)
        }

        private func setText(_ text: String, in view: UITextView) {
            view.attributedText = NSAttributedString(string: text, attributes: view.typingAttributes)
            updatePlaceholderVisibility(of: view)
        }

        private func addPlaceholder(to view: UITextView) {
            placeholderLabel.numberOfLines = 0
            placeholderLabel.isAccessibilityElement = false
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(placeholderLabel)
            let guide = view.frameLayoutGuide
            let top = placeholderLabel.topAnchor.constraint(equalTo: guide.topAnchor)
            let leading = placeholderLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor)
            let width = placeholderLabel.widthAnchor.constraint(equalTo: guide.widthAnchor)
            NSLayoutConstraint.activate([top, leading, width])
            placeholderTop = top
            placeholderLeading = leading
            placeholderWidth = width
        }

        /// 조합 중 글자도 칸 글자에 들어 있으므로, 조합이 시작되면 바로 숨는다.
        private func updatePlaceholderVisibility(of view: UITextView) {
            placeholderLabel.isHidden = !(view.text ?? "").isEmpty
        }

        private func commit(_ text: String) {
            committedText = text
            parent.text = text
        }
    }
}

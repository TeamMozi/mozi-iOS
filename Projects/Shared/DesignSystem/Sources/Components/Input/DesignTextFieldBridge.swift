import SwiftUI
import UIKit

/// 한 줄 칸의 UIKit 몸통. `UITextField` 를 감싼다.
/// 값은 쓰는 쪽이 들고, 포커스는 감싼 바깥에 건 SwiftUI `.focused` 가 잇는다.
struct DesignTextFieldBridge: UIViewRepresentable {
    @Binding var text: String
    let appearance: DesignTextInputAppearance
    /// 글자 수 규칙. nil 이면 세지 않는다.
    var limit: DesignTextLimit?
    /// 칸이 키보드를 얻으면 true, 잃으면 false. 입력 중 테두리가 쓴다.
    let onEditingChanged: @MainActor (Bool) -> Void

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        context.coordinator.configure(field)
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self
        context.coordinator.apply(appearance, to: field)
        context.coordinator.syncText(of: field)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DesignTextFieldBridge
        private var appliedAppearance: DesignTextInputAppearance?
        /// 조합이 끝났을 때 견줄, 마지막으로 받아 둔 값.
        private var committedText = ""

        init(parent: DesignTextFieldBridge) {
            self.parent = parent
        }

        func configure(_ field: UITextField) {
            field.delegate = self
            field.borderStyle = .none
            field.backgroundColor = .clear
            // 상자 전체(높이 46)를 눌러도 키보드가 뜨도록 SwiftUI 가 준 크기를 다 채운다.
            field.setContentHuggingPriority(.defaultLow, for: .horizontal)
            field.setContentHuggingPriority(.defaultLow, for: .vertical)
            field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            field.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
            apply(parent.appearance, to: field)
            syncText(of: field)
        }

        /// 모양이 바뀌었을 때만 다시 건다. 조합 중에 속성을 다시 걸면 한글 조합이 끊긴다.
        func apply(_ appearance: DesignTextInputAppearance, to field: UITextField) {
            guard appearance != appliedAppearance, field.markedTextRange == nil else { return }
            appliedAppearance = appearance
            field.defaultTextAttributes = appearance.textAttributes(includesLineHeight: false)
            field.attributedPlaceholder = NSAttributedString(
                string: appearance.placeholder,
                attributes: appearance.placeholderAttributes(includesLineHeight: false)
            )
            field.tintColor = appearance.tint.uiColor
            field.accessibilityLabel = appearance.accessibilityLabel
        }

        /// 쓰는 쪽 값을 칸에 옮긴다. 조합 중에는 칸을 건드리지 않는다.
        /// 최대보다 긴 값은 받자마자 잘라 쓰는 쪽 값도 바꾼다.
        func syncText(of field: UITextField) {
            guard field.markedTextRange == nil else { return }
            let shown = parent.limit?.incoming(parent.text) ?? parent.text
            if field.text != shown {
                field.text = shown
            }
            committedText = shown
            if shown != parent.text {
                // 화면을 그리는 도중에 바인딩을 바꾸면 SwiftUI 가 경고한다. 다음 차례로 미룬다.
                Task { @MainActor [weak self] in
                    self?.parent.text = shown
                }
            }
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            guard let limit = parent.limit else { return true }
            let current = textField.text ?? ""
            let decision = limit.decide(
                current: current,
                range: range,
                replacement: string,
                isComposing: textField.markedTextRange != nil
            )
            switch decision {
            case .accept:
                return true
            case .reject:
                return false
            case let .replace(with: fitted):
                let updated = (current as NSString).replacingCharacters(in: range, with: fitted)
                textField.text = updated
                textField.moveCursor(toUTF16Offset: range.location + (fitted as NSString).length)
                commit(updated)
                return false
            }
        }

        /// 글이 바뀔 때마다 불린다. 조합 중이면 그대로 올리고, 조합이 끝났으면 넘친 만큼 자른 뒤 올린다.
        @objc func editingChanged(_ field: UITextField) {
            let current = field.text ?? ""
            guard field.markedTextRange == nil, let limit = parent.limit else {
                parent.text = current
                return
            }
            let settled = limit.settle(current, previous: committedText)
            if settled != current {
                field.text = settled
            }
            commit(settled)
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onEditingChanged(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEditingChanged(false)
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

        private func commit(_ text: String) {
            committedText = text
            parent.text = text
        }
    }
}

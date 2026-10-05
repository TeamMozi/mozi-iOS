import UIKit

extension UITextInput {
    /// 커서를 글 처음에서 UTF-16 `offset` 만큼 떨어진 자리로 옮긴다.
    func moveCursor(toUTF16Offset offset: Int) {
        guard let position = position(from: beginningOfDocument, offset: offset) else { return }
        selectedTextRange = textRange(from: position, to: position)
    }
}

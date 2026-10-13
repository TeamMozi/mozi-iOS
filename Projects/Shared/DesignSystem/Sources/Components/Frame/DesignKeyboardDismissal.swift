import SwiftUI
import UIKit

public extension View {
    /// 입력 칸이 있는 스크롤 뷰에 붙여 키보드를 쉽게 내리게 한다.
    /// 스크롤을 시작하면 키보드를 바로 내린다. 붙인 뷰 안에서 입력 칸이 아닌 곳을 누르면 키보드를 가진 칸이 키보드를 놓는다.
    /// 누르기는 버튼·메뉴와 함께 인식되어 누른 동작도 그대로 실행된다. 입력 칸을 누르면 거르므로 다른 칸으로 옮겨도 키보드가 남는다.
    func designKeyboardDismissal() -> some View {
        scrollDismissesKeyboard(.immediately)
            .background {
                DesignKeyboardDismissalTapHost()
            }
    }
}

/// 누른 곳이 입력 칸인지 가린다.
enum DesignKeyboardDismissal {
    /// 누른 뷰가 `UITextField`·`UITextView` 이거나 그 안의 뷰면 true.
    /// 디자인 시스템 칸과 SwiftUI `TextField`·`TextEditor` 모두 이 두 UIKit 칸으로 그려진다.
    static func isTextInput(_ view: UIView?) -> Bool {
        var current = view
        while let candidate = current {
            if candidate is UITextField || candidate is UITextView {
                return true
            }
            current = candidate.superview
        }
        return false
    }
}

/// 붙인 뷰 뒤에 빈 UIKit 뷰를 깐다. 그 뷰가 창에 누르기 손짓을 단다.
private struct DesignKeyboardDismissalTapHost: UIViewRepresentable {
    func makeUIView(context: Context) -> DesignKeyboardDismissalTapView {
        DesignKeyboardDismissalTapView(frame: .zero)
    }

    func updateUIView(_ uiView: DesignKeyboardDismissalTapView, context: Context) {}
}

/// 창에 누르기 손짓을 달고, 이 뷰 영역 안에서 입력 칸이 아닌 곳을 누르면 키보드를 내린다.
/// 뒤에 깔린 뷰는 앞의 내용에 가려 터치를 받지 못하므로 손짓은 창에 단다. 창에 단 손짓은 창 안 모든 터치를 보므로
/// 이 뷰의 영역과 이 뷰가 속한 화면으로 다시 거른다. 영역만 보면 같은 창에 뜬 시트를 눌러도 영역 안 좌표라 받는다.
/// 터치를 막지 않고 다른 손짓과 함께 인식해 버튼·메뉴도 그대로 눌린다.
final class DesignKeyboardDismissalTapView: UIView, UIGestureRecognizerDelegate {
    let tapRecognizer = UITapGestureRecognizer()
    private weak var installedWindow: UIWindow?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        tapRecognizer.addTarget(self, action: #selector(handleTap))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        installedWindow?.removeGestureRecognizer(tapRecognizer)
        installedWindow = window
        window?.addGestureRecognizer(tapRecognizer)
    }

    /// 지금 키보드를 가진 칸에 키보드를 놓으라고 알린다. 화면의 포커스 상태를 몰라도 된다.
    func dismissKeyboard() {
        window?.endEditing(true)
    }

    /// `touchedView` 가 이 뷰 좌표 `point` 의 터치를 받았을 때 손짓이 받을지. 영역 밖이거나 입력 칸이면 받지 않는다.
    /// 누른 뷰가 이 뷰가 속한 화면 밖이면 받지 않는다. 누른 뷰나 화면을 모르면 남의 키보드를 내리지 않도록 받지 않는다.
    func acceptsTouch(on touchedView: UIView?, at point: CGPoint) -> Bool {
        guard let touchedView, let screenView = owningScreenView, touchedView.isDescendant(of: screenView) else {
            return false
        }
        return bounds.contains(point) && !DesignKeyboardDismissal.isTextInput(touchedView)
    }

    /// 응답 사슬에서 처음 만나는 화면(뷰 컨트롤러)의 뷰.
    private var owningScreenView: UIView? {
        var responder = next
        while let current = responder {
            if let controller = current as? UIViewController {
                return controller.view
            }
            responder = current.next
        }
        return nil
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        acceptsTouch(on: touch.view, at: touch.location(in: self))
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    @objc private func handleTap() {
        dismissKeyboard()
    }
}

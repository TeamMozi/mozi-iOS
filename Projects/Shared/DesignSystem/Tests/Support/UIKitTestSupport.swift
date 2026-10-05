@testable import SharedDesignSystem
import SwiftUI
import UIKit

/// 호스트 앱 없는 테스트에서 SwiftUI 화면을 키 창에 띄운다. 돌려받은 창은 테스트 끝까지 붙들어 둔다.
@MainActor
func showInKeyWindow(_ view: some View) -> (window: UIWindow, root: UIView) {
    let host = UIHostingController(rootView: view)
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = host
    window.makeKeyAndVisible()
    host.view.layoutIfNeeded()
    return (window, host.view)
}

/// UIKit 칸을 직접 올릴 빈 키 창. 키보드·조합 시험에 쓴다.
@MainActor
func makeKeyWindow() -> (window: UIWindow, root: UIView) {
    let controller = UIViewController()
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = controller
    window.makeKeyAndVisible()
    return (window, controller.view)
}

/// 포커스 이동·레이아웃·다음 차례로 미룬 값 쓰기가 끝나도록 주 스레드를 잠깐 돌린다.
@MainActor
func spinMainLoop(milliseconds: Int = 300) async throws {
    try await Task.sleep(for: .milliseconds(milliseconds))
}

/// 뷰 아래에서 주어진 UIKit 타입을 모두 찾는다.
@MainActor
func findSubviews<T: UIView>(of type: T.Type, in view: UIView) -> [T] {
    var result: [T] = []
    if let match = view as? T {
        result.append(match)
    }
    for child in view.subviews {
        result += findSubviews(of: type, in: child)
    }
    return result
}

extension DesignTextInputAppearance {
    /// 시험용 칸 모양. Body/Regular 와 기본 색.
    static let testBody = DesignTextInputAppearance(
        textStyle: TextStyle.ds.body.regular,
        textColor: SemanticColor.text.neutral.primary,
        placeholder: "시험",
        placeholderStyle: TextStyle.ds.body.regular,
        placeholderColor: SemanticColor.text.neutral.subtle,
        tint: SemanticColor.text.accent.default,
        accessibilityLabel: "시험 칸",
        textInsets: .zero
    )
}

import UIKit

/// 데모 버튼을 앱 창 위에 그리는 창. 화면 데모가 띄운 덮개·시트는 앱 창 안에 쌓이므로, 이 창이 그 위에 뜬다.
///
/// 버튼 자리와 버튼이 연 데모 메뉴만 터치를 받는다. 나머지 터치는 아래 앱 창으로 넘긴다.
public final class DemoMenuPassThroughWindow: UIWindow {
    /// 앱 창(`.normal`)보다 한 칸 위. 시스템 얼럿 창(`.alert`)보다는 아래다.
    public static let level = UIWindow.Level.normal + 1

    /// 창 좌표의 데모 버튼 자리. 비어 있으면 버튼 터치를 받지 않는다.
    public var buttonFrame: CGRect = .null

    override public init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        configure()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let acceptsTouch = Self.acceptsTouch(
            at: point,
            buttonFrame: buttonFrame,
            isMenuPresented: rootViewController?.presentedViewController != nil
        )
        guard acceptsTouch else { return nil }
        return super.hitTest(point, with: event)
    }

    /// 데모 메뉴가 떠 있으면 모든 터치를, 아니면 버튼 자리 안의 터치만 받는다.
    static func acceptsTouch(at point: CGPoint, buttonFrame: CGRect, isMenuPresented: Bool) -> Bool {
        isMenuPresented || buttonFrame.contains(point)
    }

    /// 화면 모드를 걸 앱 창. 데모 버튼 창이 아니고 창 높이가 `.normal` 인 첫 창이다.
    ///
    /// 데모 버튼 창이 열쇠 창이 될 수 있어(데모 메뉴를 열 때) 열쇠 창으로 고르지 않는다.
    public static func appWindow(among windows: [UIWindow]) -> UIWindow? {
        windows.first { !($0 is DemoMenuPassThroughWindow) && $0.windowLevel == .normal }
    }

    private func configure() {
        windowLevel = Self.level
        backgroundColor = .clear
    }
}

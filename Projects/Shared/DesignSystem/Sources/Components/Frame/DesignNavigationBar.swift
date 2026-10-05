import UIKit

/// 시스템 뒤로 가기 버튼의 그림만 디자인 시스템 `chevron.left` 로 바꾼다. 버튼과 밀어서 돌아가기는 시스템 것이다.
public enum DesignNavigationBar {
    /// 앱 시작에서 한 번 부른다. 이후 만들어지는 모든 내비게이션 바에 걸린다.
    @MainActor
    public static func applyBackIndicator() {
        let appearance = makeAppearance()
        let proxy = UINavigationBar.appearance()
        proxy.standardAppearance = appearance
        proxy.compactAppearance = appearance
        proxy.scrollEdgeAppearance = appearance
        proxy.compactScrollEdgeAppearance = appearance
    }

    /// 템플릿 그림이라 색은 시스템이 칠한다.
    @MainActor
    static var backIndicatorImage: UIImage {
        SharedDesignSystemAsset.iconChevronLeft.image.withRenderingMode(.alwaysTemplate)
    }

    // iOS 26 기본 헤더처럼 바탕을 칠하지 않는다. 채움 헤더는 화면이 `.designHeaderBackground(.filled)` 로 덮는다.
    @MainActor
    static func makeAppearance() -> UINavigationBarAppearance {
        let image = backIndicatorImage
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.setBackIndicatorImage(image, transitionMaskImage: image)
        return appearance
    }
}

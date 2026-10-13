import UIKit

/// 데모 메뉴의 「화면 모드」 칸. 값은 디자인 시스템 화면과 같은 `GalleryAppearance` 를 쓴다.
/// 시스템은 기기 모드를 덮어쓰지 않는다. 고른 모드는 기억하지 않아, 화면 데모를 새로 열면 시스템이다.
public enum DemoMenuAppearance {
    public static let title = "화면 모드"
    public static var options: [GalleryAppearance] { GalleryAppearance.allCases }
    public static var initial: GalleryAppearance { .system }

    /// 고른 모드를 앱 창에 거는 값. 창에 걸어야 이미 떠 있는 덮개·시트까지 바로 바뀐다.
    public static func interfaceStyle(for appearance: GalleryAppearance) -> UIUserInterfaceStyle {
        switch appearance {
        case .system: .unspecified
        case .dark: .dark
        case .light: .light
        }
    }
}
